//
//  DexListRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexListRepositoryProtocol {

    func list(by pairs: [API.DTO.Pair]) -> Observable<[API.DTO.ListPair]>
}
