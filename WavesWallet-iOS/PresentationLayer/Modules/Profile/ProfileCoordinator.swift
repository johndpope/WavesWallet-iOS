//
//  ProfileCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import StoreKit
import MessageUI

private enum Constants {
    static let supporURL = URL(string: "https://support.wavesplatform.com/")!
    static let supportEmail = "mobileapp@wavesplatform.com"
}

final class ProfileCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    private let authorization = FactoryInteractors.instance.authorization
    private let navigationController: UINavigationController
    private let disposeBag: DisposeBag = DisposeBag()

    init(navigationController: UINavigationController, applicationCoordinator: ApplicationCoordinatorProtocol?) {
        self.applicationCoordinator = applicationCoordinator
        self.navigationController = navigationController
    }

    func start() {
        let vc = ProfileModuleBuilder(output: self).build()
        self.navigationController.pushViewController(vc, animated: true)
        setupBackupTost(target: vc, navigationController: navigationController, disposeBag: disposeBag)
    }
}

// MARK: ProfileModuleOutput

extension ProfileCoordinator: ProfileModuleOutput {

    func showBackupPhrase(wallet: DomainLayer.DTO.Wallet, saveBackedUp: @escaping ((_ isBackedUp: Bool) -> Void)) {

        authorization
            .authorizedWallet()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (signedWallet) in

                guard let owner = self else { return }

                let seed = signedWallet.seedWords

                if wallet.isBackedUp == false {

                    let backup = BackupCoordinator(navigationController: owner.navigationController,
                                                   seed: seed,
                                                   completed: { [weak self] needBackup in
                        saveBackedUp(!needBackup)
                        self?.navigationController.popToRootViewController(animated: true)
                    })
                    owner.addChildCoordinatorAndStart(childCoordinator: backup)
                } else {
                    let vc = StoryboardScene.Backup.saveBackupPhraseViewController.instantiate()
                    vc.input = .init(seed: seed, isReadOnly: true)
                    owner.navigationController.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    func showAddressesKeys(wallet: DomainLayer.DTO.Wallet) {
        guard let applicationCoordinator = self.applicationCoordinator else { return }
        let coordinator = AddressesKeysCoordinator(navigationController: navigationController, wallet: wallet, applicationCoordinator: applicationCoordinator)
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showAddressBook() {
        let vc = AddressBookModuleBuilder.init(output: nil).build(input: .init(isEditMode: true))
        self.navigationController.pushViewController(vc, animated: true)
    }

    func showLanguage() {
        let language = StoryboardScene.Language.languageViewController.instantiate()
        language.delegate = self
        navigationController.pushViewController(language, animated: true)
    }

    func showNetwork(wallet: DomainLayer.DTO.Wallet) {
        let vc = NetworkSettingsModuleBuilder(output: self).build(input: .init(wallet: wallet))
        navigationController.pushViewController(vc, animated: true)
    }

    func showRateApp() {
        RateApp.show()
    }

    func showFeedback() {

        let coordinator = MailComposeCoordinator(viewController: navigationController, email: Constants.supportEmail)
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showSupport() {
        UIApplication.shared.openURLAsync(Constants.supporURL)
    }

    func accountSetEnabledBiometric(isOn: Bool, wallet: DomainLayer.DTO.Wallet) {
        let passcode = PasscodeCoordinator(navigationController: navigationController, kind: .setEnableBiometric(isOn, wallet: wallet))
        passcode.delegate = self
        addChildCoordinator(childCoordinator: passcode)
        passcode.start()
    }

    func showChangePasscode(wallet: DomainLayer.DTO.Wallet) {
        let passcode = PasscodeCoordinator(navigationController: navigationController, kind: .changePasscode(wallet))
        passcode.delegate = self
        addChildCoordinator(childCoordinator: passcode)
        passcode.start()
    }

    func showChangePassword(wallet: DomainLayer.DTO.Wallet) {
        let vc = ChangePasswordModuleBuilder(output: self).build(input: .init(wallet: wallet))
        self.navigationController.pushViewController(vc, animated: true)
    }

    func accountLogouted() {
        self.applicationCoordinator?.showEnterDisplay()
    }

    func accountDeleted() {
        self.applicationCoordinator?.showEnterDisplay()
    }
}

// MARK: PasscodeCoordinatorDelegate

extension ProfileCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet) {}

    func passcodeCoordinatorWalletLogouted() {
        applicationCoordinator?.showEnterDisplay()
    }

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {
    }
}

// MARK: LanguageViewControllerDelegate

extension ProfileCoordinator: LanguageViewControllerDelegate {
    func languageViewChangedLanguage() {
        navigationController.popViewController(animated: true)
    }
}

// MARK: ChangePasswordModuleOutput

extension ProfileCoordinator: ChangePasswordModuleOutput {
    func changePasswordCompleted(wallet: DomainLayer.DTO.Wallet, newPassword: String, oldPassword: String) {
        let passcode = PasscodeCoordinator(navigationController: navigationController,
                                           kind: .changePassword(wallet: wallet,
                                                                 newPassword: newPassword,
                                                                 oldPassword: oldPassword))
        passcode.delegate = self
        addChildCoordinator(childCoordinator: passcode)
        passcode.start()
    }
}

// MARK: NetworkSettingsModuleOutput

extension ProfileCoordinator: NetworkSettingsModuleOutput {

    func networkSettingSavedSetting() {
        NotificationCenter.default.post(name: .changedSpamList, object: nil)
        navigationController.popViewController(animated: true)
    }
}


