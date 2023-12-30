//
//  SignViewModel.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/08/10.
//

import AuthenticationServices
import Combine
import Foundation

final class SignViewModel: NSObject, BaseViewModelType {
    
    // MARK: - property
    
    private let usecase: SignUsecase
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let isLoginSubject: PassthroughSubject<Result<Bool, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let appleSignButtonDidTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let isLogin: AnyPublisher<Result<Bool, Error>, Never>
    }
    
    func transform(from input: Input) -> Output {
        input.appleSignButtonDidTap
            .sink(receiveValue: { [weak self] _ in
                self?.didTapAppleSignButton()
            })
            .store(in: &self.cancellable)
        
        return Output(isLogin: self.isLoginSubject.eraseToAnyPublisher())
    }
    
    // MARK: - init
    
    init(usecase: SignUsecase) {
        self.usecase = usecase
    }
    
    // MARK: - func
    
    private func didTapAppleSignButton() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        @Configurations(key: ConfigurationsKey.nonce, defaultValue: "")
        var nonce: String

        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.sha256

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    // MARK: - network
    
    private func dispatchLogin(login: SignRequestDTO) {
        Task {
            do {
                let token = try await self.usecase.dispatchAppleLogin(login: login)
                
                KeychainManager.set(token.accessToken, for: .accessToken)
                KeychainManager.set(token.refreshToken, for: .refreshToken)
                UserDefaultHandler.setIsLogin(isLogin: true)
                
                self.getMyProfile()
            } catch {
                self.isLoginSubject.send(.failure(NetworkError()))
            }
        }
    }
    
    private func getMyProfile() {
        Task {
            do {
                let profile = try await self.usecase.getMyProfile()
                
                UserDefaultHandler.setId(id: profile.id)
                UserDefaultHandler.setNickname(nickname: profile.nickname)
                
                self.isLoginSubject.send(.success(true))
            } catch {
                self.isLoginSubject.send(.failure(NetworkError()))
            }
        }
    }
}

extension SignViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        guard let token = credential.identityToken else { return }
        guard let tokenToString = String(data: token, encoding: .utf8) else { return }
        
        let signDTO = SignRequestDTO(appleToken: tokenToString)
        self.dispatchLogin(login: signDTO)
    }
}
