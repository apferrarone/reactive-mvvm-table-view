//
//  SceneDelegate.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
    var window: UIWindow?
    var topNavigationController: UINavigationController!
    var coordinator: AppCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // setup root navigation controller
        self.topNavigationController = UINavigationController()
        self.topNavigationController.navigationBar.barStyle = .black
        self.topNavigationController.navigationBar.prefersLargeTitles = false
        
        // setup main window
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = self.topNavigationController
        self.window?.makeKeyAndVisible()
        
        // setup coordinator
        self.coordinator = Coordinator(rootViewController: self.topNavigationController)
        self.coordinator.start()
    }
}

