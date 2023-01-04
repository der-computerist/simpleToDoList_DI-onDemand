//
//  LandingViewControllerTests.swift
//  ToDoListUITests
//
//  Created by Enrique Aliaga on 11/8/22.
//

import XCTest
@testable import ToDoList

final class LandingViewControllerTests: XCTestCase {
    
    // MARK: - Properties
    var activityRepository: (NSObject & ActivityRepository)!
    var appDelegate: AppDelegate!
    var mainViewController: MainViewController!
    var landingViewController: LandingViewController!

    // MARK: - Methods
    override func setUp() {
        activityRepository = constructTestingRepository()
        
        let tuple = constructTestingViews(activityRepository: activityRepository)
        appDelegate = tuple.0
        mainViewController = tuple.1
        landingViewController = tuple.2
    }
    
    override func tearDown() {
        activityRepository = nil
    }
    
    // MARK: Test Methods
    func test_startupConfiguration() {
        let viewControllers = mainViewController.viewControllers
        XCTAssert(viewControllers.first as? LandingViewController == landingViewController)
        
        let restorationIdentifier = landingViewController.restorationIdentifier
        XCTAssert(restorationIdentifier == "LandingViewController")
        
        let navigationItemTitle = landingViewController.navigationItem.title
        XCTAssert(navigationItemTitle == "To Do List")
        
        let delegate = landingViewController.delegate as? MainViewController
        XCTAssert(delegate === mainViewController)
        
        let navigationItemLeftButtonTitle =
            landingViewController.navigationItem.leftBarButtonItem?.title
        XCTAssert(navigationItemLeftButtonTitle == "Edit")
        
        let navigationItemRightButton = landingViewController.navigationItem.rightBarButtonItem
        XCTAssert(navigationItemRightButton?.target === landingViewController)
        XCTAssert(navigationItemRightButton?.action ==
                #selector(LandingViewController.handleAddButtonPressed(sender:)))
    }
    
    func test_enterEditingMode() {
        guard let activitiesVC =
           landingViewController.children[0] as? ActivitiesViewController else {
            XCTFail("Child view controller is missing.")
            return
        }
        landingViewController.setEditing(true, animated: false)
        XCTAssertTrue(activitiesVC.isEditing)
        XCTAssertTrue(activitiesVC.tableView.isEditing)
    }
    
    func test_exitEditingMode() {
        guard let activitiesVC =
           landingViewController.children[0] as? ActivitiesViewController else {
            XCTFail("Child view controller is missing.")
            return
        }
        landingViewController.setEditing(false, animated: false)
        XCTAssertFalse(activitiesVC.isEditing)
        XCTAssertFalse(activitiesVC.tableView.isEditing)
    }
    
    func test_createNewActivity() throws {
        guard let navigationItemRightButton =
           landingViewController.navigationItem.rightBarButtonItem else {
            XCTFail("Add button item is missing.")
            return
        }
        landingViewController.handleAddButtonPressed(sender: navigationItemRightButton)
        let navController =
            try XCTUnwrap(landingViewController.presentedViewController as? UINavigationController)
        let activityDetailVC =
            try XCTUnwrap(navController.topViewController as? ActivityDetailViewController)
        XCTAssert(activityDetailVC.navigationItem.title == "New Activity")
        landingViewController.dismiss(animated: false, completion: nil)
    }
    
    func test_modelObservation() {
        let activitiesCountLabel =
            (landingViewController.view as! LandingRootView).activitiesCountLabel
        
        var kvoExpectation: XCTKVOExpectation
        let kvoTimeout = 2.0
        var result: XCTWaiter.Result

        // Pre-insertion
        kvoExpectation = XCTKVOExpectation(keyPath: "text",
                                           object: activitiesCountLabel,
                                           expectedValue: "Total: 5")
        result = XCTWaiter().wait(for: [kvoExpectation], timeout: kvoTimeout)
        XCTAssert(result == .completed)
        
        // Test insertion
        var activity6 = Activity(name: "Play Uncharted Drake's Fortune",
                                 description: "On the PlayStation 5",
                                 status: .pending,
                                 id: UUID().uuidString,
                                 dateCreated: Date())
        activityRepository.update(activity: activity6)
        
        kvoExpectation = XCTKVOExpectation(keyPath: "text",
                                           object: activitiesCountLabel,
                                           expectedValue: "Total: 6",
                                           options: .new)
        result = XCTWaiter().wait(for: [kvoExpectation], timeout: kvoTimeout)
        XCTAssert(result == .completed)

        // Test replacement
        activity6 = Activity(name: "Play Uncharted 2: Among Thieves",
                             description: activity6.activityDescription,
                             status: activity6.status,
                             id: activity6.id,
                             dateCreated: activity6.dateCreated)
        activityRepository.update(activity: activity6)
        
        kvoExpectation = XCTKVOExpectation(keyPath: "text", object: activitiesCountLabel)
        result = XCTWaiter().wait(for: [kvoExpectation], timeout: kvoTimeout)
        XCTAssert(result == .timedOut)  // because no KVO notification is expected
        XCTAssert(activitiesCountLabel.text == "Total: 6")

        // Test removal
        activityRepository.delete(activity: activity6)
        
        kvoExpectation = XCTKVOExpectation(keyPath: "text",
                                           object: activitiesCountLabel,
                                           expectedValue: "Total: 5",
                                           options: .new)
        result = XCTWaiter().wait(for: [kvoExpectation], timeout: kvoTimeout)
        XCTAssert(result == .completed)
    }
    
    // MARK: Private
    private func constructTestingRepository() -> NSObject & ActivityRepository {
        let activityDataStore = FakeActivityDataStore()
        return ToDoListActivityRepository(dataStore: activityDataStore)
    }
    
    private func constructTestingViews(activityRepository: NSObject & ActivityRepository) ->
       (AppDelegate, MainViewController, LandingViewController) {
        
        let activitiesVC = ActivitiesViewController(activityRepository: activityRepository)
        let landingVC = LandingViewController(
            activitiesViewController: activitiesVC,
            activityRepository: activityRepository
        )
        let mainVC = MainViewController(
            landingViewController: landingVC,
            activityRepository: activityRepository
        )
        
        landingVC.delegate = mainVC
        activitiesVC.delegate = mainVC
        
        landingVC.loadViewIfNeeded()
        
        let appDelegate = AppDelegate()
        
        let window = UIWindow()
        window.rootViewController = mainVC
        appDelegate.window = window
        
        window.makeKeyAndVisible()
        return (appDelegate, mainVC, landingVC)
    }
}
