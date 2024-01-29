//
//  SignAPI.swift
//  FoodBowl
//
//  Created by Coby on 1/29/24.
//

import Foundation

import Moya

enum SignAPI {
    case signIn(request: SignRequestDTO)
    case logOut
    case patchRefreshToken(token: TokenDTO)
}

extension SignAPI: TargetType {
    var baseURL: URL {
        @Configurations(key: ConfigurationsKey.baseURL, defaultValue: "")
        var baseURL: String
        return URL(string: baseURL)!
    }

    var path: String {
        switch self {
        case .signIn:
            return "/v1/auth/login/oauth/apple"
        case .logOut:
            return "/v1/auth/logout"
        case .patchRefreshToken:
            return "/v1/auth/token/renew"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signIn, .logOut, .patchRefreshToken:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .signIn(let request):
            return .requestJSONEncodable(request)
        case .patchRefreshToken(let request):
            let request = TokenDTO(
                accessToken: request.accessToken,
                refreshToken: request.refreshToken
            )
            return .requestJSONEncodable(request)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        let accessToken: String = KeychainManager.get(.accessToken)
        
        switch self {
        case .signIn:
            return [
                "Content-Type": "application/json"
            ]
        default:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer " + accessToken
            ]
        }
    }

    var validationType: ValidationType { .successCodes }
}
