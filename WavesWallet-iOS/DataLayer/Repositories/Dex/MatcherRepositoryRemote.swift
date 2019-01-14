//
//  MatcherRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

final class MatcherRepositoryRemote: MatcherRepositoryProtocol {

    private let matcherProvider: MoyaProvider<Matcher.Service.MatcherPublicKey> = .matcherMoyaProvider()
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }
    
    func matcherPublicKey(accountAddress: String) -> Observable<PublicKeyAccount> {
        
        return environmentRepository.accountEnvironment(accountAddress: accountAddress)
            .flatMap({ (environment) -> Observable<PublicKeyAccount> in
                
                return self.matcherProvider.rx
                    .request(.init(environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .asObservable()
                    .flatMap({ (response) -> Observable<PublicKeyAccount>  in
                        
                        do {
                            let key = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? String ?? ""
                            return Observable.just(PublicKeyAccount(publicKey: Base58.decode(key)))
                        }
                        catch let error {
                            return Observable.error(error)
                        }
                    })
            })
    }
}
