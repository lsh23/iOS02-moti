//
//  HomeViewModel.swift
//
//
//  Created by Kihyun Lee on 11/14/23.
//

import Foundation
import Domain

final class HomeViewModel {
    enum HomeViewModelAction {
        case fetchData
    }
    
    enum CategoryState {
        case none
        case loading
        case finish
        case error(message: String)
    }
    
    enum AchievementState {
        case none
        case loading
        case finish
        case error(message: String)
    }
    
    typealias AchievementDataSource = ListDiffableDataSource<Achievement>
    typealias CategoryDataSource = ListDiffableDataSource<String>
    
    private var categoryDataSource: CategoryDataSource?
    
    private var achievementDataSource: AchievementDataSource?
    private let fetchAchievementListUseCase: FetchAchievementListUseCase
    
    private var categories: [String] = [
        "글자 크기가1",
        "다른 문자열입니다.2",
        "글자3",
        "크기가 다른4",
        "문자열5",
        "글자 크기가6",
        "다른 문자열입니다.7",
        "글자8",
        "크기가 다른9",
        "문자열10",
        "글자 크기가11",
        "다른 문자열입니다.12",
        "글자13",
        "크기가 다른14",
        "문자열15",
        "글자 크기가16",
        "다른 문자열입니다.17",
        "글자18",
        "크기가 다른19",
        "문자열20"
    ]
    private var achievements: [Achievement] = []
    
    @Published private(set) var categoryState: CategoryState = .none
    @Published private(set) var achievementState: AchievementState = .none
    
    init(
        fetchAchievementListUseCase: FetchAchievementListUseCase
    ) {
        self.fetchAchievementListUseCase = fetchAchievementListUseCase
    }
    
    func action(_ action: HomeViewModelAction) {
        switch action {
        case .fetchData:
            fetchCategories()
            fetchAchievementList()
        }
    }
    
    func setupCategoryDataSource(_ dataSource: CategoryDataSource) {
        self.categoryDataSource = dataSource
    }
    
    func setupAchievementDataSource(_ dataSource: AchievementDataSource) {
        self.achievementDataSource = dataSource
    }
    
    private func fetchCategories() {
        categoryDataSource?.update(data: categories)
    }
    
    private func fetchAchievementList() {
        Task {
            do {
                achievementState = .loading
                achievements = try await fetchAchievementListUseCase.execute()
                achievementState = .finish
                achievementDataSource?.update(data: achievements)
            } catch {
                achievementState = .error(message: error.localizedDescription)
            }
        }
    }
}
