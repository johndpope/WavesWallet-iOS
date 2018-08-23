//
//  DexTraderContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexTraderContainerViewController: UIViewController {

    @IBOutlet weak var segmentedControl: DexTraderContainerSegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pair: DexTraderContainer.DTO.Pair!
    weak var moduleOutput: DexTraderContainerModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.delegate = self
        title = pair.amountAsset.name + " / " + pair.priceAsset.name
        createBackWhiteButton()
        addBgBlueImage()
        addInfoButton()
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSmallNavigationBar()
        hideTopBarLine()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = nil
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for view in scrollView.subviews {
            view.frame.size = scrollView.bounds.size
        }
    }
}

//MARK: - Actions
private extension DexTraderContainerViewController {
    
    @objc func infoTapped() {
        let infoPair = DexInfoPair.DTO.Pair(amountAsset: pair.amountAsset.id, amountAssetName: pair.amountAsset.name, priceAsset: pair.priceAsset.id, priceAssetName: pair.priceAsset.name, isHidden: pair.isHidden)
        moduleOutput?.showInfo(pair: infoPair)
    }
    
}

//MARK: - DexTranderContainerSegmentedControlDelegate
extension DexTraderContainerViewController: DexTraderContainerSegmentedControlDelegate {
    
    func segmentedControlDidChangeState(_ state: DexTraderContainerSegmentedControl.SegmentedState) {
        scrollToPageIndex(state.rawValue)
    }
}

//MARK: - UIScrollViewDelegate
extension DexTraderContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        segmentedControl.changeStateToScrollPage(scrollView.currentPage)
    }
}


//MARK: - Setup UI
private extension DexTraderContainerViewController {
    
    func scrollToPageIndex(_ pageIndex: Int) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(pageIndex) * scrollView.frame.size.width,
                                            y: scrollView.contentOffset.y), animated: true)
    }
    
    func addInfoButton() {
        let btn = UIBarButtonItem(image: Images.topbarInfowhite.image, style: .plain, target: self, action: #selector(infoTapped))
        btn.tintColor = .white
        navigationItem.rightBarButtonItem = btn
    }
    
    func build() {
        let numberOrScreens = 4
        
        let orderIndex = DexTraderContainerSegmentedControl.SegmentedState.orderBook.rawValue
        addController(DexOrderBookModuleBuilder().build(input: pair), atIndex: orderIndex)
        
        let chartIndex = DexTraderContainerSegmentedControl.SegmentedState.chart.rawValue
        addController(DexChartModuleBuilder().build(), atIndex: chartIndex)
        
        let lastTradesIndex = DexTraderContainerSegmentedControl.SegmentedState.lastTraders.rawValue
        addController(DexLastTradesModuleBuilder().build(input: pair), atIndex: lastTradesIndex)
        
        let myOrdersIndex = DexTraderContainerSegmentedControl.SegmentedState.myOrders.rawValue
        addController(DexMyOrdersModuleMuilder().build(), atIndex: myOrdersIndex)
        
        scrollView.contentSize = CGSize(width: CGFloat(numberOrScreens) * Platform.ScreenWidth, height: scrollView.contentSize.height)
    }
    
    func addController(_ viewController: UIViewController, atIndex: Int) {
        scrollView.addSubview(viewController.view)
        viewController.view.frame = scrollView.bounds
        viewController.view.frame.origin.x = CGFloat(atIndex) * Platform.ScreenWidth
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
    }
}
