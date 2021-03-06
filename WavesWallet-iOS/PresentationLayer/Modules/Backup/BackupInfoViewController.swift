//
//  NewAccountBackupInfoViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit


protocol BackupInfoViewModuleOutput: AnyObject {
    func userReadedBackupInfo()
}

final class BackupInfoViewController: UIViewController {

    @IBOutlet private weak var topLogoOffset: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var iUnderstandButton: UIButton!

    weak var output: BackupInfoViewModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()


        iUnderstandButton.setBackgroundImage(UIColor.submit300.image, for: .highlighted)
        iUnderstandButton.setBackgroundImage(UIColor.submit400.image, for: .normal)
        createBackButton()
        navigationItem.shadowImage = UIImage()
        navigationItem.backgroundImage = UIImage()        
        titleLabel.text = Localizable.Waves.Backup.Infobackup.Label.title
        detailLabel.text = Localizable.Waves.Backup.Infobackup.Label.detail
        iUnderstandButton.setTitle(Localizable.Waves.Backup.Infobackup.Button.iunderstand, for: .normal)
    }

    @IBAction func understandTapped(_ sender: Any) {
        output?.userReadedBackupInfo()
    }
}
