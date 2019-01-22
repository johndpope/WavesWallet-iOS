//
//  DexCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

final class DexCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private let disposeBag: DisposeBag = DisposeBag()

    private lazy var dexListViewContoller: UIViewController = {
        return DexListModuleBuilder(output: self).build()
    }()

    private var navigationRouter: NavigationRouter

    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    func start() {

        navigationRouter.pushViewController(dexListViewContoller)
        setupBackupTost(target: dexListViewContoller, navigationRouter: navigationRouter, disposeBag: disposeBag)
    }
    
    private var containerControllers: [UIViewController] {
        for controller in navigationRouter.navigationController.viewControllers {
            if let vc = controller as? DexTraderContainerViewController {
                return vc.controllers
            }
        }
        return []
    }
}


//MARK: - DexListModuleOutput, DexMarketModuleOutput, DexTraderContainerModuleOutput
extension DexCoordinator: DexListModuleOutput, DexMarketModuleOutput, DexTraderContainerModuleOutput {
    
    func showDexSort(delegate: DexListRefreshOutput) {
        let vc = DexSortModuleBuilder(output: delegate).build()
        navigationRouter.pushViewController(vc)
    }
    
    func showAddList(delegate: DexListRefreshOutput) {
        let vc = DexMarketModuleBuilder(output: self).build(input: delegate)
        navigationRouter.pushViewController(vc)
    }
    
    func showTradePairInfo(pair: DexTraderContainer.DTO.Pair) {

        let vc = DexTraderContainerModuleBuilder(output: self, orderBookOutput: self, lastTradesOutput: self, myOrdersOutpout: self).build(input: pair)
        navigationRouter.pushViewController(vc)
    }
    
    func showInfo(pair: DexInfoPair.DTO.Pair) {
        
        let controller = DexInfoModuleBuilder().build(input: pair)
        let popup = PopupViewController()
        popup.contentHeight = 300
        popup.present(contentViewController: controller)
    }
}

//MARK: - DexLastTradesModuleOutput
extension DexCoordinator: DexLastTradesModuleOutput {
    
    func didCreateOrder(_ trade: DexLastTrades.DTO.SellBuyTrade, amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, availableAmountAssetBalance: Money, availablePriceAssetBalance: Money, availableWavesBalance: Money) {
        
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: trade.type,
                                  price: trade.price, ask: nil, bid: nil, last: nil,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance,
                                  availableWavesBalance: availableWavesBalance,
                                  inputMaxAmount: false)
    }
    
    func didCreateEmptyOrder(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, orderType: DomainLayer.DTO.Dex.OrderType, availableAmountAssetBalance: Money, availablePriceAssetBalance: Money, availableWavesBalance: Money) {
        
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: orderType,
                                  price: nil, ask: nil, bid: nil, last: nil,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance,
                                  availableWavesBalance: availableWavesBalance,
                                  inputMaxAmount: false)
        
    }
}

//MARK: - DexOrderBookModuleOutput
extension DexCoordinator:  DexOrderBookModuleOutput {
    
    func didCreateOrder(_ bidAsk: DexOrderBook.DTO.BidAsk, amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, ask: Money?, bid: Money?, last: Money?, availableAmountAssetBalance: Money, availablePriceAssetBalance: Money, availableWavesBalance: Money, inputMaxAmount: Bool) {
        
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: bidAsk.orderType,
                                  price: bidAsk.price, ask: ask, bid: bid, last: last,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance,
                                  availableWavesBalance: availableWavesBalance,
                                  inputMaxAmount: inputMaxAmount)

    }
    
    
    func didCreateEmptyOrder(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, orderType: DomainLayer.DTO.Dex.OrderType, ask: Money?, bid: Money?, last: Money?, availableAmountAssetBalance: Money, availablePriceAssetBalance: Money, availableWavesBalance: Money) {
        
        showCreateOrderController(amountAsset: amountAsset, priceAsset: priceAsset, type: orderType,
                                  price: nil, ask: ask, bid: bid, last: last,
                                  availableAmountAssetBalance: availableAmountAssetBalance,
                                  availablePriceAssetBalance: availablePriceAssetBalance,
                                  availableWavesBalance: availableWavesBalance,
                                  inputMaxAmount: false)
        
    }
}

//MARK: - CreateOrderController
private extension DexCoordinator {
    
    func showCreateOrderController(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, type: DomainLayer.DTO.Dex.OrderType,
                                   price: Money?, ask: Money?, bid: Money?, last: Money?,
                                   availableAmountAssetBalance: Money, availablePriceAssetBalance: Money,
                                   availableWavesBalance: Money,
                                   inputMaxAmount: Bool) {
        
        var lastPrice: Money?
        if let last = last, last.amount > 0 {
            lastPrice = last
        }
        
        let input = DexCreateOrder.DTO.Input(amountAsset: amountAsset, priceAsset: priceAsset, type: type,
                                             price: price, ask: ask, bid: bid, last: lastPrice,
                                             availableAmountAssetBalance: availableAmountAssetBalance,
                                             availablePriceAssetBalance: availablePriceAssetBalance,
                                             availableWavesBalance: availableWavesBalance,
                                             inputMaxAmount: inputMaxAmount)
       
        let controller = DexCreateOrderModuleBuilder(output: self).build(input: input)
        let popup = PopupViewController()
        popup.present(contentViewController: controller)
    }
}

extension DexCoordinator: DexCreateOrderModuleOutput {
    func dexCreateOrderDidCreate(output: DexCreateOrder.DTO.Output) {

        let controller = DexCompleteOrderModuleBuilder().build(input: output)
        navigationRouter.pushViewController(controller)
   
        for controller in containerControllers {
            if let vc = controller as? DexCreateOrderProtocol {
                vc.updateCreatedOrders()
            }
        }
    }
}

extension DexCoordinator: DexMyOrdersModuleOutput {
    func myOrderDidCancel() {
        for controller in containerControllers {
            if let vc = controller as? DexCancelOrderProtocol {
                vc.updateCanceledOrders()
            }
        }
    }
}
