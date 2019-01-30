//
//  WavesPopupViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RESideMenu

protocol WavesPopupModuleOutput: AnyObject {
    func showSend()
    func showReceive()
    func showExchange()
}

final class WavesPopupViewController: UIViewController {

    weak var moduleOutput: WavesPopupModuleOutput?
    @IBOutlet weak var comingSoonLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var exchangeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        comingSoonLabel.text = Localizable.Waves.Wavespopup.Label.comingsoon
        sendButton.setTitle(Localizable.Waves.Wavespopup.Button.send, for: .normal)
        receiveButton.setTitle(Localizable.Waves.Wavespopup.Button.receive, for: .normal)
        exchangeButton.setTitle(Localizable.Waves.Wavespopup.Button.exchange, for: .normal)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlerScrollPanGesture(recognizer:)))
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
    }

    @IBAction func sendTapped(_ sender: Any) {

        moduleOutput?.showSend()
        dismissTapped(sender)
    }
    
    
    @IBAction func receiveTapped(_ sender: Any) {
        
        moduleOutput?.showReceive() 
        dismissTapped(sender)
    }
    
    
    @IBAction func exchangeTapped(_ sender: Any) {
        moduleOutput?.showExchange()
    }

    @IBAction func dismissTapped(_ sender: Any) {
        if let parent = parent as? PopupViewController {
            parent.dismissPopup()
        }
    }

    @objc func handlerScrollPanGesture(recognizer: UIPanGestureRecognizer) {
//        self.dismiss(animated: true, completion: nil)
    }
}

extension WavesPopupViewController: UIGestureRecognizerDelegate {


}

extension WavesPopupViewController: PopoverPresentationAnimatorContext {

    func contectHeight(for size: CGSize) -> CGFloat {
        return 305
    }

}
