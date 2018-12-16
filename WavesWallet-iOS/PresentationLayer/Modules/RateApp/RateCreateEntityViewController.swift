//
//  RateEntityCreateViewController.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RateCreateEntityViewController: UIViewController {

    @IBOutlet fileprivate var nameTextField: InputTextField!
    @IBOutlet fileprivate var attachmentTextField: InputTextField!

    @IBOutlet fileprivate var titleSeedLabel: UILabel!
    @IBOutlet fileprivate var seedLabel: UILabel!
    @IBOutlet fileprivate var resetButton: UIButton!
    @IBOutlet fileprivate var createEntityButton: UIButton!

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

    fileprivate func createEntity() {

        guard let privateKey = self.privateKeyAccount else { return }

        let name = self.nameTextField.value?.trimmingCharacters(in: .whitespaces) ?? ""
        let attachment = self.attachmentTextField.value?.trimmingCharacters(in: .whitespaces) ?? ""

        guard name.count > 0 else { return }
        guard attachment.count > 0 else { return }


        authorizationInteractor
            .authorizedWallet()
            .flatMap { [weak self] (wallet) -> Observable<DomainLayer.DTO.SmartTransaction> in
                guard let owner = self else { return Observable.never() }
                return owner
                    .transactionsInteractor
                    .send(by: .data(.init(fee: GlobalConstants.WavesTransactionFeeAmount,
                                          data: [.init(key: "image", value: .binary(Array(SupportViewController.image.utf8)))])),
                          wallet: wallet)
            }
            .subscribe()

        
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
