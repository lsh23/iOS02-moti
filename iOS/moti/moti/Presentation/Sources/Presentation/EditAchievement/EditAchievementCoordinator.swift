//
//  EditAchievementCoordinator.swift
//  
//
//  Created by 유정주 on 11/23/23.
//

import UIKit
import Core
import Data
import Domain

protocol EditAchievementCoordinatorDelegate: AnyObject {
    func doneButtonDidClicked(achievement: Achievement)
}

final class EditAchievementCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: EditAchievementCoordinatorDelegate?
    
    init(
        _ navigationController: UINavigationController,
        _ parentCoordinator: Coordinator?
    ) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
    }
    
    func start() {
        
    }
    
    func start(achievement: Achievement) {
        let achievementRepository = AchievementRepository()
        let editAchievementVM = EditAchievementViewModel(
            saveImageUseCase: .init(repository: ImageRepository()),
            fetchCategoryListUseCase: .init(repository: CategoryListRepository()),
            updateAchievementUseCase: .init(repository: achievementRepository, categoryStorage: CategoryStorage.shared),
            postAchievementUseCase: .init(repository: achievementRepository, categoryStorage: CategoryStorage.shared)
        )
        let editAchievementVC = EditAchievementViewController(
            viewModel: editAchievementVM,
            achievement: achievement
        )
        editAchievementVC.coordinator = self
        editAchievementVC.delegate = self
        
        editAchievementVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소", style: .plain, target: self,
            action: #selector(cancelButtonAction)
        )
        
        let navVC = UINavigationController(rootViewController: editAchievementVC)
        navigationController.present(navVC, animated: true)
    }
    
    func start(achievement: Achievement, group: Group) {
        let groupAchievementRepository = GroupAchievementRepository(groupId: group.id)
        let editAchievementVM = EditAchievementViewModel(
            saveImageUseCase: .init(repository: ImageRepository()),
            fetchCategoryListUseCase: .init(repository: GroupCategoryRepository(groupId: group.id)),
            updateAchievementUseCase: .init(repository: groupAchievementRepository, categoryStorage: nil),
            postAchievementUseCase: .init(repository: groupAchievementRepository, categoryStorage: nil)
        )
        let editAchievementVC = EditAchievementViewController(
            viewModel: editAchievementVM,
            achievement: achievement
        )
        editAchievementVC.coordinator = self
        editAchievementVC.delegate = self
        
        editAchievementVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소", style: .plain, target: self,
            action: #selector(cancelButtonAction)
        )
        
        let navVC = UINavigationController(rootViewController: editAchievementVC)
        navigationController.present(navVC, animated: true)
    }
    
    func startAfterCapture(image: UIImage) {
        let achievementRepository = AchievementRepository()
        let editAchievementVM = EditAchievementViewModel(
            saveImageUseCase: .init(repository: ImageRepository()),
            fetchCategoryListUseCase: .init(repository: CategoryListRepository()),
            updateAchievementUseCase: .init(repository: achievementRepository, categoryStorage: CategoryStorage.shared),
            postAchievementUseCase: .init(repository: achievementRepository, categoryStorage: CategoryStorage.shared)
        )
        let editAchievementVC = EditAchievementViewController(
            viewModel: editAchievementVM,
            image: image
        )
        editAchievementVC.coordinator = self
        editAchievementVC.delegate = self
        
        editAchievementVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "다시 촬영", style: .plain, target: self,
            action: #selector(recaptureButtonAction)
        )
        
        navigationController.pushViewController(editAchievementVC, animated: false)
        navigationController.setNavigationBarHidden(false, animated: false)
    }
    
    @objc private func cancelButtonAction() {
        parentCoordinator?.dismiss(child: self, animated: true)
    }
    
    @objc private func recaptureButtonAction() {
        finish(animated: false)
    }
}

extension EditAchievementCoordinator: EditAchievementViewControllerDelegate {
    func doneButtonDidClickedFromDetailView(updatedAchievement: Achievement) {
        parentCoordinator?.dismiss(child: self, animated: true)
        delegate?.doneButtonDidClicked(achievement: updatedAchievement)
    }
    
    func doneButtonDidClickedFromCaptureView(newAchievement: Achievement) {
        delegate?.doneButtonDidClicked(achievement: newAchievement)
        navigationController.setNavigationBarHidden(true, animated: false)
        finish(animated: false)
        parentCoordinator?.finish(animated: true)
    }
}
