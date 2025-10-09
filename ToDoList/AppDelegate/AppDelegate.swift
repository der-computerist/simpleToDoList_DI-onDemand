//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        let activitiesVC = ActivitiesViewController(
            activityRepository: GlobalToDoListActivityRepository
        )
        let landingVC = LandingViewController(
            activitiesViewController: activitiesVC,
            activityRepository: GlobalToDoListActivityRepository
        )
        let mainVC = MainViewController(
            landingViewController: landingVC,
            activityRepository: GlobalToDoListActivityRepository
        )
        
        landingVC.delegate = mainVC
        activitiesVC.delegate = mainVC
        
        window = UIWindow()
        window?.rootViewController = mainVC
        
        window?.makeKeyAndVisible()
        return true
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let mainVC = window?.rootViewController as! MainViewController
        
        // If state restoration occurred, we'll want to set back up some relationships
        // between view controllers.
        if let navController = mainVC.presentedViewController as? NiblessNavigationController,
           let activityDetailVC = navController.children[0] as? ActivityDetailViewController {
            
            navController.presentationController?.delegate = activityDetailVC
            activityDetailVC.delegate = mainVC
        }
        
        return true
    }

    // MARK: - State Restoration
    func application(_ _: UIApplication, shouldSaveSecureApplicationState _: NSCoder) -> Bool {
        true
    }
    
    func application(_ _: UIApplication, shouldRestoreSecureApplicationState _: NSCoder) -> Bool {
        true
    }
    
    func application(
        _ application: UIApplication,
        viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder
    ) -> UIViewController? {
        
        var viewController: UIViewController?
        let restorationIdentifier = identifierComponents.last
        
        switch restorationIdentifier {
        case ActivitiesViewController.Restoration.viewControllerIdentifier:
            viewController = window?.rootViewController?.children[0].children[0]
        default:
            break
        }
        
        return viewController
    }
}
