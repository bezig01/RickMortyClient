//
//  SceneDelegate.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import UIKit
import Network

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var alertWindow: UIWindow?
    
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        let viewController = CharactersViewController()
        let nav = UINavigationController()
        nav.viewControllers = [viewController]
        
        window?.rootViewController = nav
        
        monitor.pathUpdateHandler = { path in
            guard path.status != .satisfied else { return }
            print("No connection.")
            DispatchQueue.main.async { [weak self] in
                self?.presentAlert(windowScene)
            }
        }
        
        monitor.start(queue: queue)
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate),
           !appDelegate.isUserLoggedIn {
            
            let viewController = LoginViewController()
            viewController.isModalInPresentation = true
            
            let nav = UINavigationController()
            nav.viewControllers = [viewController]
            
            window?.rootViewController?.present(nav, animated: true)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

extension SceneDelegate {
    
    func presentAlert(_ windowScene: UIWindowScene) {
        let alertController = UIAlertController(title: nil, message: "No connection.", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .cancel) { [weak self] action in
            alertController.dismiss(animated: true, completion: nil)
            self?.alertWindow?.resignKey()
            self?.alertWindow = nil
            }

        alertController.addAction(dismissAction)

        let alertWindow = UIWindow(windowScene: windowScene)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = .alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        
        self.alertWindow = alertWindow
    }
    
    func initialScreen() {
        
        guard let window else { return }
        
        let viewController = CharactersViewController()
        let nav = UINavigationController()
        nav.viewControllers = [viewController]
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = nav
        }) { _ in
            
             let viewController = LoginViewController()
             viewController.isModalInPresentation = true
             
             let nav = UINavigationController()
             nav.viewControllers = [viewController]
             
             window.rootViewController?.present(nav, animated: true)
        }
    }
}
