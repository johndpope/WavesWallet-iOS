//
//  DexRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexRealmRepositoryProtocol {
    
    func save(pair: DomainLayer.DTO.Dex.AssetPair, accountAddress: String) -> Observable<Bool>
    func delete(by id: String, accountAddress: String) -> Observable<Bool> 
    func list(by accountAddress: String) -> Observable<[DomainLayer.DTO.Dex.AssetPair]>
    func listListener(by accountAddress: String) -> Observable<[DomainLayer.DTO.Dex.AssetPair]>

}
