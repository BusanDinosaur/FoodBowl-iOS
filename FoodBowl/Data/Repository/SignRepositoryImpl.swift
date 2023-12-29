//
//  SignRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

import Foundation

import Moya

final class SignRepositoryImpl: SignRepository {

    private let provider = MoyaProvider<ServiceAPI>()
    
    func checkNickname(nickname: String) async throws -> CheckNicknameDTO {
        let response = await provider.request(.checkNickname(nickname: nickname))
        return try response.decode()
    }
    
    func signIn(request: SignRequestDTO) async throws -> TokenDTO {
        let response = await provider.request(.signIn(request: request))
        return try response.decode()
    }
    
    func logOut() async throws {
        let _ = await provider.request(.logOut)
    }
}
