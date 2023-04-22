//
//  MainViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 3/17/22.
//

import UIKit

public final class MainViewController: NiblessNavigationController {
    
    // MARK: - Properties
    private let landingViewController: LandingViewController
    private var activityDetailViewController: ActivityDetailViewController?
    private let activityRepository: ActivityRepository
    
    // MARK: - Methods
    public init(
        landingViewController: LandingViewController,
        activityRepository: ActivityRepository
    ) {
        self.landingViewController = landingViewController
        self.activityRepository = activityRepository
        super.init()
        restorationIdentifier = Restoration.viewControllerIdentifier
    }
    
    // MARK: View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        presentActivityList()
    }
    
    // MARK: Private
    private func presentActivityList() {
        pushViewController(landingViewController, animated: false)
    }
    
    private func presentActivityCreationScreen() {
        let detailViewController = ActivityDetailViewController(
            activity: nil,
            activityRepository: activityRepository
        )
        detailViewController.delegate = self
        
        let navController = NiblessNavigationController(rootViewController: detailViewController)
        navController.restorationIdentifier = Restoration.navControllerIdentifier
        navController.restorationClass = type(of: self)
        navController.presentationController?.delegate = detailViewController
        
        present(navController, animated: true)
        activityDetailViewController = detailViewController
    }
    
    private func presentActivityUpdateScreen(activity: Activity) {
        let detailViewController = ActivityDetailViewController(
            activity: activity,
            activityRepository: activityRepository
        )
        detailViewController.delegate = self
        
        let navController = NiblessNavigationController(rootViewController: detailViewController)
        navController.restorationIdentifier = Restoration.navControllerIdentifier
        navController.restorationClass = type(of: self)
        navController.presentationController?.delegate = detailViewController
        
        present(navController, animated: true)
        activityDetailViewController = detailViewController
    }
}

// MARK: - LandingViewControllerDelegate
extension MainViewController: LandingViewControllerDelegate {
    
    public func landingViewControllerAddButtonWasTapped(_ _: LandingViewController) {
        presentActivityCreationScreen()
    }
}

// MARK: - ActivitiesViewControllerDelegate
extension MainViewController: ActivitiesViewControllerDelegate {
    
    public func activitiesViewController(
        _ _: ActivitiesViewController,
        didSelectActivity activity: Activity
    ) {
        presentActivityUpdateScreen(activity: activity)
    }
}

// MARK: - ActivityDetailViewControllerDelegate
extension MainViewController: ActivityDetailViewControllerDelegate {
    
    public func activityDetailViewControllerDidCancel(_ _: ActivityDetailViewController) {
        activityDetailViewController = nil
        dismiss(animated: true)
    }
    
    public func activityDetailViewControllerDidFinish(_ _: ActivityDetailViewController) {
        activityDetailViewController = nil
        dismiss(animated: true)
    }
}

// MARK: - State Restoration
extension MainViewController {

    public override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(activityDetailViewController,
            forKey: Restoration.Key.activityDetailViewController)
    }

    public override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        if let activityDetailVC = coder.decodeObject(of: ActivityDetailViewController.self,
           forKey: Restoration.Key.activityDetailViewController) {
            activityDetailViewController = activityDetailVC
        }
    }
}

extension MainViewController: UIViewControllerRestoration {
    
    public static func viewController(
        withRestorationIdentifierPath identifierComponents: [String],
        coder: NSCoder
    ) -> UIViewController? {
        
        var viewController: UIViewController?
        let restorationIdentifier = identifierComponents.last
        
        switch restorationIdentifier {
        case Restoration.navControllerIdentifier:
            let navController = NiblessNavigationController()
            navController.restorationIdentifier = restorationIdentifier
            navController.restorationClass = self
            viewController = navController
        default:
            break
        }
        
        return viewController
    }
}

// MARK: - Constants
extension MainViewController {
    
    struct Restoration {
        static let viewControllerIdentifier  = String(describing: MainViewController.self)
        static let navControllerIdentifier   = String(describing: NiblessNavigationController.self)
        
        struct Key {
            static let activityDetailViewController = "activityDetailViewController"
        }
    }
}
