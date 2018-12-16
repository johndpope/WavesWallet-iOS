//
//  RateEntityCreateViewController.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RXSwift
import RXCocoa

final class RateCreateEntityViewController: UIViewController {

    @IBOutlet private var nameTextField: InputTextField!
    @IBOutlet private var attachmentTextField: InputTextField!

    @IBOutlet private var titleSeedLabel: UILabel!
    @IBOutlet private var seedLabel: UILabel!
    @IBOutlet private var resetButton: UIButton!
    @IBOutlet private var createEntityButton: UIButton!

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let transactionsInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions
    private var privateKeyAccount: PrivateKeyAccount?

    override func viewDidLoad() {
        super.viewDidLoad()

        createEntityButton.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        createEntityButton.setBackgroundImage(UIColor.submit400.image, for: .normal)


        navigationItem.shadowImage = UIViewController.cleanShadowImage
        navigationItem.title = "Create entity"
        navigationItem.barTintColor = .white
        setupBigNavigationBar()
        setupTextField()
        cleanData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameTextField.becomeFirstResponder()
    }

    private func setupTextField() {

        nameTextField.autocapitalizationType = .none
        attachmentTextField.autocapitalizationType = .none

        nameTextField.update(with: InputTextField.Model(title: "Name",
                                                           kind: .text,
                                                           placeholder: "Name"))
        attachmentTextField.update(with: InputTextField.Model(title: "Attachment",
                                                        kind: .text,
                                                        placeholder: "Attachment"))

        nameTextField.returnKey = .next
        attachmentTextField.returnKey = .done

        nameTextField.textFieldShouldReturn = { [weak self] _ in
            self?.attachmentTextField.becomeFirstResponder()
        }

        attachmentTextField.textFieldShouldReturn = { [weak self] _ in
            self?.attachmentTextField.resignFirstResponder()
            self?.createEntity()
        }
    }

    @IBAction func tapResetButton() {
        cleanData()
    }
    
    @IBAction func tapCreatyEntityButton() {
        createEntity()
    }

    private func createEntity() {

        guard let privateKey = self.privateKey else { return }
        guard self.nameTextField.text.trimmingCharacters(in: .whitespaces).count else { return }
        guard self.attachmentTextField.text.trimmingCharacters(in: .whitespaces).count else { return }

        let name = self.nameTextField.text
        let attachment = self.attachmentTextField.text

//        authorizationInteractor
//            .authorizedWallet()
//            .flatMap { [weak self] (wallet) -> Observable<DomainLayer.DTO.SmartTransaction> in
//                guard let owner = self else { return Observable.never() }
//                return self
//                    .transactionsInteractor
//                    .send(by: .data(.init(fee: GlobalConstants.WavesTransactionFeeAmount,
//                                          data: [.init(key: "image", value: .binary(Array(SupportViewController.image.utf8)))])),
//                          wallet: wallet)
//            }
//            .subscribe()

        
    }

    private func cleanData() {
        nameTextField.value = nil
        attachmentTextField.value = nil

        let seed = WordList.generatePhrase()
        let privateKey = PrivateKeyAccount(seedStr: seed)
        seedLabel.text = privateKey.address
        self.privateKeyAccount = privateKey
    }
}
