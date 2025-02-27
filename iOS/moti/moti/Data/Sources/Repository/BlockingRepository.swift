//
//  BlockingRepository.swift
//
//
//  Created by 유정주 on 12/6/23.
//

import Foundation
import Domain

public struct BlockingRepository: BlockingRepositoryProtocol {
    private let provider: ProviderProtocol
    private let groupId: Int
    
    public init(provider: ProviderProtocol = Provider(), groupId: Int) {
        self.provider = provider
        self.groupId = groupId
    }
    
    public func blockingUser(userCode: String) async throws -> Bool {
        let endpoint = MotiAPI.blockingUser(userCode: userCode)
        let responseDTO = try await provider.request(with: endpoint, type: BlockingDTO.self)
        return responseDTO.success ?? false
    }
    
    public func blockingAchievement(achievementId: Int) async throws -> Bool {
        let endpoint = MotiAPI.blockingAchievement(achievementId: achievementId, groupId: groupId)
        let responseDTO = try await provider.request(with: endpoint, type: BlockingDTO.self)
        return responseDTO.success ?? false
    }
}
