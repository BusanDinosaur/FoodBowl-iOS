//
//  FollowerViewModel.swift
//  FoodBowl
//
//  Created by Coby on 12/21/23.
//

import Combine
import UIKit

import CombineMoya
import Moya

final class FollowerViewModel: NSObject, BaseViewModelType {
    
    // MARK: - property
    
    private let provider = MoyaProvider<ServiceAPI>()
    private var cancelBag = Set<AnyCancellable>()
    
    let isOwn: Bool
    private let memberId: Int
    
    private let size: Int = 20
    private var currentPage: Int = 0
    private var currentSize: Int = 20
    
    private let followersSubject = PassthroughSubject<[MemberByFollow], Error>()
    private let moreFollowersSubject = PassthroughSubject<[MemberByFollow], Error>()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let followers: PassthroughSubject<[MemberByFollow], Error>
        let moreFollowers: PassthroughSubject<[MemberByFollow], Error>
    }
    
    // MARK: - init

    init(memberId: Int) {
        self.memberId = memberId
        self.isOwn = UserDefaultsManager.currentUser?.id ?? 0 == memberId
    }
    
    // MARK: - Public - func
    
    func transform(from input: Input) -> Output {
        let viewDidLoad = input.viewDidLoad
            .compactMap { [weak self] in self?.getFollowersPublisher() }
            .eraseToAnyPublisher()
        
        input.scrolledToBottom
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getFollowersPublisher()
            })
            .store(in: &self.cancelBag)
        
        return Output(
            followers: followersSubject,
            moreFollowers: moreFollowersSubject
        )
    }
}

// MARK: - network
extension FollowerViewModel {
    func followMember(memberId: Int) async -> Bool {
        let response = await provider.request(.followMember(memberId: memberId))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }
    
    func unfollowMember(memberId: Int) async -> Bool {
        let response = await provider.request(.unfollowMember(memberId: memberId))
        switch response {
        case .success:
            return false
        case .failure(let err):
            handleError(err)
            return true
        }
    }
    
    func removeFollowingMember(memberId: Int) async -> Bool {
        let response = await provider.request(.removeFollower(memberId: memberId))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }
    
    private func getFollowersPublisher() {
        if currentSize < size { return }
        
        provider.requestPublisher(
            .getFollowerMember(
                memberId: memberId,
                page: currentPage,
                size: size
            )
        )
        .sink { completion in
            switch completion {
            case let .failure(error):
                self.followersSubject.send(completion: .failure(error))
            case .finished:
                break
            }
        } receiveValue: { recievedValue in
            guard let responseData = try? recievedValue.map(FollowMemberResponse.self) else { return }
            self.currentPage = responseData.currentPage
            self.currentSize = responseData.currentSize
            
            if self.currentPage == 0 {
                self.followersSubject.send(responseData.content)
            } else {
                self.moreFollowersSubject.send(responseData.content)
            }
            
        }
        .store(in : &cancelBag)
    }
}
