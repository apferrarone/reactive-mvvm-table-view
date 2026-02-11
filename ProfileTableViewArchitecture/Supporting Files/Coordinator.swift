//
//  Coordinator.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

@MainActor
protocol AppCoordinator: AnyObject
{
    var rootViewController: UINavigationController { get }
    func start()
}

@MainActor
final class Coordinator: NSObject, AppCoordinator
{
    var rootViewController: UINavigationController
        
    init(rootViewController: UINavigationController)
    {
        self.rootViewController = rootViewController
        super.init()
    }
        
    func start()
    {
        self.showProfile()
    }
    
    func showProfile()
    {
        let viewModel = ProfileViewModel()
        let profileController = ProfileViewController(viewModel: viewModel)
        self.rootViewController.viewControllers = [profileController]
    }
}
