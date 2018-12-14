//
//  String+NormalizeAssetId.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 08/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {

    var normalizeAssetId: String {
        if let id = self {
            return id
        } else {
            return GlobalConstants.wavesAssetId
        }
    }
}

extension String {
    func normalizeAddress(environment: Environment) -> String {

        if let range = self.range(of: environment.aliasScheme), self.contains(environment.aliasScheme) {
            var newString = self
            newString.removeSubrange(range)
            return newString
        }

        return self
    }
}

extension String {
    func toUInt() -> UInt? {
        let scanner = Scanner(string: self)
        var u: UInt64 = 0
        if scanner.scanUnsignedLongLong(&u)  && scanner.isAtEnd {
            return UInt(u)
        }
        return nil
    }
}
