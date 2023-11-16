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
        
        viewModel.fetchVersion()
    }
    
    private func bind() {
        viewModel.$version
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] version in
                guard let self else { return }
                
                sleep(1)
                viewModel.fetchToken()
            }
            .store(in: &cancellables)
        
        viewModel.$isSuccessLogin
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] isSuccessLogin in
                guard let self else { return }
                
                delegate?.viewControllerDidLogin(isSuccess: isSuccessLogin)
                coordinator?.finish(animated: false)
            }
            .store(in: &cancellables)
        
    }
}
