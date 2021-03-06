//
//  MatcherService.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension Matcher.Service {
    
    struct MatcherPublicKey {
        var environment: Environment
    }
}

extension Matcher.Service.MatcherPublicKey: MatcherTargetType {
    var path: String {
        return "matcher"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
}
