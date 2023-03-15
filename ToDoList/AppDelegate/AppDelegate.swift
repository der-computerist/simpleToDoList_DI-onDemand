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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
