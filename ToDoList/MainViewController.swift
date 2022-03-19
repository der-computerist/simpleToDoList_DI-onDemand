//
//  MainViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 3/17/22.
//

import Foundation

public final class MainViewController: NiblessNavigationController {
    
    // MARK: - Properties
    private let landingViewController: LandingViewController
    private var activityDetailViewController: ActivityDetailViewController?
    
    // MARK: - Methods
    public init(landingViewController: LandingViewController) {
        self.landingViewController = landingViewController
        super.init()
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
            for: .newActivity(GlobalToDoListActivityRepository.emptyActivity)
        )
        detailViewController.delegate = self
        
        let navController = NiblessNavigationController(rootViewController: detailViewController)
        navController.presentationController?.delegate = detailViewController
        
        present(navController, animated: true)
        activityDetailViewController = detailViewController
    }
    
    private func presentActivityUpdateScreen(activity: Activity) {
        let detailViewController = ActivityDetailViewController(for: .existingActivity(activity))
        detailViewController.delegate = self
        
        let navController = NiblessNavigationController(rootViewController: detailViewController)
        navController.presentationController?.delegate = detailViewController
        
        present(navController, animated: true)
        activityDetailViewController = detailViewController
    }
}

// MARK: - LandingViewControllerDelegate

extension MainViewController: LandingViewControllerDelegate {
    
    func landingViewControllerShouldCreateActivity(_ _: LandingViewController) {
        presentActivityCreationScreen()
    }
}

// MARK: - ActivitiesViewControllerDelegate

extension MainViewController: ActivitiesViewControllerDelegate {
    
    func activitiesViewController(
        _ _: ActivitiesViewController,
        didSelectActivity activity: Activity
    ) {
        presentActivityUpdateScreen(activity: activity)
    }
    
    func activitiesViewController(_ _: ActivitiesViewController, didDeleteActivity _: Activity) {
        landingViewController.updateActivitiesCountLabel()
    }
}

// MARK: - ActivityDetailViewControllerDelegate

extension MainViewController: ActivityDetailViewControllerDelegate {
    
    func activityDetailViewControllerDidCancel(_ _: ActivityDetailViewController) {
        dismiss(animated: true)
    }
    
    func activityDetailViewControllerDidFinish(
        _ activityDetailViewController: ActivityDetailViewController
    ) {
        if case .newActivity = activityDetailViewController.flow {
            landingViewController.updateActivitiesCountLabel()
        }
        landingViewController.activitiesViewController.tableView.reloadData()

        dismiss(animated: true)
    }
}
