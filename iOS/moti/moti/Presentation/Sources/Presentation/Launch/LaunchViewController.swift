//
//  LaunchViewController.swift
//  moti
//
//  Created by 유정주 on 11/8/23.
//

import UIKit
import Combine
import Core

protocol LaunchViewControllerDelegate: AnyObject {
    func viewControllerDidLogin(isSuccess: Bool)
}

final class LaunchViewController: BaseViewController<LaunchView> {
    
    // MARK: - Properties
    weak var coordinator: LaunchCoodinator?
    weak var delegate: LaunchViewControllerDelegate?
    
    private let viewModel: LaunchViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: LaunchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
        viewModel.action(.launch)
    }
    
    private func bind() {
        viewModel.$versionState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .none: break
                case .loading:
                    layoutView.update(progressMessage: "버전을 가져오는 중")
                case .finish:
                    layoutView.update(progressMessage: "자동 로그인 시도 중")
                    viewModel.action(.autoLogin)
                case .error(let message):
                    Logger.error("Launch Version Error: \(message)")
                }
            }
            .store(in: &cancellables)
        
        viewModel.$autoLoginState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .none: break
                case .loading:
                    layoutView.update(progressMessage: "자동 로그인 시도 중")
                    Logger.debug("자동 로그인 진행 중")
                case .success:
                    layoutView.update(progressMessage: "자동 로그인 성공")
                    Logger.debug("자동 로그인 성공")
                    delegate?.viewControllerDidLogin(isSuccess: true)
                    coordinator?.finish(animated: false)
                case .failed(let message):
                    layoutView.update(progressMessage: "자동 로그인 실패")
                    Logger.debug("자동 로그인 실패: \(message)")
                    delegate?.viewControllerDidLogin(isSuccess: false)
                    coordinator?.finish(animated: false)
                }
            }
            .store(in: &cancellables)
    }
}
