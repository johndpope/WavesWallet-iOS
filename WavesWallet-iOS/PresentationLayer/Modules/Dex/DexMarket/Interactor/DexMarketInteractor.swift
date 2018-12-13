import Foundation
import RxSwift
import SwiftyJSON
import RealmSwift
import Alamofire

final class DexMarketInteractor: DexMarketInteractorProtocol {
    
    private static var allPairs: [DexMarket.DTO.Pair] = []
    private static var isEnableSpam = false
    private static var spamURL = ""

    private let searchPairsSubject: PublishSubject<[DexMarket.DTO.Pair]> = PublishSubject<[DexMarket.DTO.Pair]>()
    private let disposeBag: DisposeBag = DisposeBag()

    private let repository: DexRepositoryProtocol = FactoryRepositories.instance.dexRepository
    private let authorizationInteractor = FactoryInteractors.instance.authorization
    private let account: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
    private let accountSettings: AccountSettingsRepositoryProtocol = FactoryRepositories.instance.accountSettingsRepository
    private let environment = FactoryRepositories.instance.environmentRepository
    
    func pairs() -> Observable<[DexMarket.DTO.Pair]> {

        return authorizationInteractor.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DexMarket.DTO.Pair]> in
            
            guard let owner = self else { return Observable.empty() }
            return owner.accountSettings.accountSettings(accountAddress: wallet.address).flatMap({ [weak self] (accountSettings) -> Observable<[DexMarket.DTO.Pair]> in
                
                guard let owner = self else { return Observable.empty() }
                let isEnableSpam = accountSettings?.isEnabledSpam ?? DexMarketInteractor.isEnableSpam

                return owner.environment.accountEnvironment(accountAddress: wallet.address).flatMap({ [weak self] (environment) -> Observable<[DexMarket.DTO.Pair]> in
                    
                    guard let owner = self else { return Observable.empty() }
                    return owner.allPairs(accountAddress: wallet.address, isEnableSpam: isEnableSpam, spamURL: environment.servers.spamUrl.relativeString)
                })
            })
        })
    }
    
    func searchPairs() -> Observable<[DexMarket.DTO.Pair]> {
        return searchPairsSubject.asObserver()
    }
    
    func checkMark(pair: DexMarket.DTO.Pair) {
        
        if let index = DexMarketInteractor.allPairs.index(where: {$0.id == pair.id}) {
           
            DexMarketInteractor.allPairs[index] = pair.mutate {

                let needSaveAssetPair = !$0.isChecked
                let pair = $0
                
                $0.isChecked = !$0.isChecked
                
                authorizationInteractor.authorizedWallet().flatMap { [weak self] wallet -> Observable<Bool> in
                        
                    guard let owner = self else { return Observable.never() }

                    if needSaveAssetPair {
                        return owner.repository.save(pair: pair, accountAddress: wallet.address)
                    }
                    return owner.repository.delete(by: pair.id, accountAddress: wallet.address)
                    
                }.subscribe().disposed(by: disposeBag)
            }
        }
    }
    
    func searchPair(searchText: String) {
        
        if searchText.count > 0 {
            
            let searchPairs = DexMarketInteractor.allPairs.filter {
                searchPair(amountName: $0.amountAsset.name,
                           priceName: $0.priceAsset.name,
                           amountShortName: $0.amountAsset.shortName,
                           priceShortName: $0.priceAsset.shortName,
                           searchText: searchText)
            }
            
            searchPairsSubject.onNext(searchPairs)
        }
        else {
            searchPairsSubject.onNext(DexMarketInteractor.allPairs)
        }
    }
    
}

//MARK: - Search

private extension DexMarketInteractor {
    
    func searchPair(amountName: String, priceName: String, amountShortName: String, priceShortName: String, searchText: String) -> Bool {
        
        let searchCompoments = searchText.components(separatedBy: "/")
        if searchCompoments.count == 1 {
            
            let searchWords = searchCompoments[0].components(separatedBy: " ").filter {$0.count > 0}
            
            return isValidSearchAsset(name: amountName, shortName: amountShortName, searchWords: searchWords) ||
                isValidSearchAsset(name: priceName, shortName: priceShortName, searchWords: searchWords)
        }
        else if searchCompoments.count >= 2 {
            
            let searchAmountWords = searchCompoments[0].components(separatedBy: " ").filter {$0.count > 0}
            let searchPriceWords = searchCompoments[1].components(separatedBy: " ").filter {$0.count > 0}

            if searchPriceWords.count > 0 {
                return isValidSearchAsset(name: amountName, shortName: amountShortName, searchWords: searchAmountWords) &&
                    isValidSearchAsset(name: priceName, shortName: priceShortName, searchWords: searchPriceWords)
            }
            return isValidSearchAsset(name: amountName, shortName: amountShortName, searchWords: searchAmountWords)
        }
        
        return false
    }
    
    func isValidSearchAsset(name: String, shortName: String, searchWords: [String]) -> Bool {
        
        for word in searchWords {
            let isValid = isValidSearch(inputText: name, searchText: word) ||
                isValidSearch(inputText: shortName, searchText: word)
            if !isValid {
                return false
            }
        }
        return true
    }
    
    func isValidSearch(inputText: String, searchText: String) -> Bool {
        return (inputText.lowercased() as NSString).range(of: searchText.lowercased()).location != NSNotFound
    }
}

//MARK: - Load data
private extension DexMarketInteractor {
    
    func allPairs(accountAddress: String, isEnableSpam: Bool, spamURL: String) -> Observable<[DexMarket.DTO.Pair]> {
        
        return Observable.create({ [weak self] (subscribe) -> Disposable in

            if DexMarketInteractor.allPairs.count > 0 &&
                isEnableSpam == DexMarketInteractor.isEnableSpam &&
                spamURL == DexMarketInteractor.spamURL {
                
                let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
                
                for (index, pair) in DexMarketInteractor.allPairs.enumerated() {
                    DexMarketInteractor.allPairs[index] = pair.mutate {
                        $0.isChecked = realm.object(ofType: DexAssetPair.self, forPrimaryKey: pair.id) != nil
                    }
                }
                
                subscribe.onNext(DexMarketInteractor.allPairs)
                subscribe.onCompleted()
            }
            else {
                guard let owner = self else { return Disposables.create() }
                
                if isEnableSpam {
                    owner.getSpamList(spamURL, complete: { (spamList) in
                        owner.getAllPairs(accountAddress: accountAddress, spamList: spamList, complete: { (pairs) in
                            DexMarketInteractor.allPairs = pairs
                            DexMarketInteractor.isEnableSpam = isEnableSpam
                            DexMarketInteractor.spamURL = spamURL
                            
                            subscribe.onNext(pairs)
                            subscribe.onCompleted()
                        })
                    })
                }
                else {
                    owner.getAllPairs(accountAddress: accountAddress, spamList: [], complete: { (pairs) in
                        DexMarketInteractor.allPairs = pairs
                        DexMarketInteractor.isEnableSpam = isEnableSpam
                        DexMarketInteractor.spamURL = spamURL
                        
                        subscribe.onNext(pairs)
                        subscribe.onCompleted()
                    })
                }
            }

            return Disposables.create()
        })
    }
    
    func getSpamList(_ spamURL: String, complete:@escaping(_ spamList: [String]) -> Void) {
        
        Alamofire.request(spamURL, method: .get, parameters: nil, headers: ["Content-type": "application/csv"])
            .responseData { (response) in

                var spamList: [String] = []
                if let data = response.data {
                    spamList = (try? SpamCVC.addresses(from: data)) ?? []
                }
                complete(spamList)
        }
    }
    
    func getAllPairs(accountAddress: String, spamList:[String], complete:@escaping(_ pairs: [DexMarket.DTO.Pair]) -> Void) {
      
        NetworkManager.getRequestWithUrl(GlobalConstants.Matcher.orderBook, parameters: nil, complete: { (info, error) in
            
            var pairs: [DexMarket.DTO.Pair] = []
            
            if let info = info {
                
                let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
                
                let spamListKeys = spamList.reduce(into:  [String:String](), { $0[$1] = $1})
                for item in info["markets"].arrayValue {
                    
                    let pair = DexMarket.DTO.Pair(item, realm: realm)
                    
                    if spamListKeys[pair.amountAsset.id] == nil &&
                        spamListKeys[pair.priceAsset.id] == nil {
                        pairs.append(pair)
                    }
                }
                
                pairs = self.sort(pairs: pairs, realm: realm)
            }
            
            complete(pairs)
        })
    }
}


//MARK: - Sort
private extension DexMarketInteractor {
    
    func sort(pairs: [DexMarket.DTO.Pair], realm: Realm) -> [DexMarket.DTO.Pair] {

        var sortedPairs: [DexMarket.DTO.Pair] = []

        let generalBalances = realm
            .objects(Asset.self)
            .filter(NSPredicate(format: "isGeneral == true"))
            .toArray()
            .reduce(into: [String: Asset](), { $0[$1.id] = $1 })

        let settingsList = realm
            .objects(AssetBalanceSettings.self)
            .toArray()
            .filter { (asset) -> Bool in
                return generalBalances[asset.assetId]?.isGeneral == true
            }
            .sorted(by: { $0.sortLevel < $1.sortLevel })

        for settings in settingsList {
            sortedPairs.append(contentsOf: pairs.filter({$0.amountAsset.id == settings.assetId && $0.isGeneral == true }))
        }

        var sortedIds = sortedPairs.map {$0.id}
        sortedPairs.append(contentsOf: pairs.filter { $0.isGeneral == true && !sortedIds.contains($0.id) } )

        sortedIds = sortedPairs.map {$0.id}
        sortedPairs.append(contentsOf: pairs.filter { !sortedIds.contains($0.id) } )

        return sortedPairs
    }
}
