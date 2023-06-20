//
//  ActivityUpdateTests.swift
//  ToDoListTests
//
//  Created by Enrique Aliaga on 1/12/23.
//

import XCTest
@testable import ToDoList

final class ActivityUpdateTests: XCTestCase {
    
    // MARK: - Properties
    var activityRepository: (NSObject & ActivityRepository)!
    var appDelegate: AppDelegate!
    var mainViewController: MainViewController!
    var activityDetailViewController: ActivityDetailViewController!
    var expectation: XCTestExpectation?
    var timeout = 3.0
    
    // MARK: - Methods
    override func setUpWithError() throws {
        activityRepository = constructTestingRepository()
        
        let tuple = try constructTestingViews(activityRepository: activityRepository)
        appDelegate = tuple.0
        mainViewController = tuple.1
        activityDetailViewController = tuple.2
    }

    override func tearDown() {
        activityRepository = nil
    }

    // MARK: Test Methods
    func test_startupConfiguration() throws {
        let navController = try XCTUnwrap(
            mainViewController.presentedViewController as? UINavigationController
        )
        let topController = try XCTUnwrap(
            navController.topViewController as? ActivityDetailViewController
        )
        XCTAssert(topController === activityDetailViewController)
        
        let delegate = activityDetailViewController.delegate as? MainViewController
        XCTAssert(delegate === mainViewController)
        
        // State Restoration
        let restorationID = activityDetailViewController.restorationIdentifier
        XCTAssert(restorationID == "ActivityDetailViewController")
        
        let restorationClass = activityDetailViewController.restorationClass
        XCTAssert(restorationClass === type(of: activityDetailViewController))
        
        // Title
        let navigationItemTitle = activityDetailViewController.navigationItem.title
        XCTAssert(navigationItemTitle == "Details")
        
        // "Cancel" button item
        let navigationItemLeftButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.leftBarButtonItem
        )
        XCTAssert(navigationItemLeftButton.target === activityDetailViewController)
        XCTAssert(navigationItemLeftButton.action ==
                #selector(ActivityDetailViewController.handleCancelPressed(sender:)))
        XCTAssertTrue(navigationItemLeftButton.isEnabled)
        
        // "Edit" button item
        let navigationItemRightButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.rightBarButtonItem
        )
        XCTAssert(navigationItemRightButton.title == "Edit")
        XCTAssertTrue(navigationItemRightButton.isEnabled)
        
        // Verify initial state of input fields
        let rootView = activityDetailViewController.view as! ActivityDetailRootView
        XCTAssertFalse(rootView.nameField.isEnabled)
        XCTAssertFalse(rootView.descriptionTextView.isUserInteractionEnabled)
        XCTAssertFalse(rootView.statusStackView.isHidden)
        XCTAssertFalse(rootView.doneSwitch.isEnabled)
    }
    
    func test_enterEditingMode() throws {
        let editButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.rightBarButtonItem
        )
        
        // Tap on "Edit" button
        activityDetailViewController.setEditing(true, animated: false)
        XCTAssert(editButton.title == "Done")

        // Expect "Edit" button item to be disabled
        expectation = expectation(
            for: NSPredicate(format: "isEnabled == false"),
            evaluatedWith: editButton
        )
        waitForExpectations(timeout: timeout)
    }
    
    func test_doneButtonActivation() throws {
        let rootView = activityDetailViewController.view as! ActivityDetailRootView
        let nameField = rootView.nameField
        let descriptionTextView = rootView.descriptionTextView
        let doneButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.rightBarButtonItem
        )
        
        // Enter editing mode
        activityDetailViewController.setEditing(true, animated: false)
        
        // Immediately after entering editing mode, since there are no changes yet,
        // the "Done" button should be disabled.
        XCTAssertTrue(doneButton.isEnabled)
        
        // Typing in a name change should enable the button
        _ = activityDetailViewController.textField(
            nameField,
            shouldChangeCharactersIn: NSMakeRange(0, 20),
            replacementString: "Play Forza Motorsport"
        )
        rootView.layoutIfNeeded()
        XCTAssertTrue(doneButton.isEnabled)
        
        // Restoring the name back to its original value should disable the button
        _ = activityDetailViewController.textField(
            nameField,
            shouldChangeCharactersIn: NSMakeRange(0, 20),
            replacementString: "Play Forza Horizon 5"
        )
        rootView.layoutIfNeeded()
        XCTAssertFalse(doneButton.isEnabled)
        
        // Typing in a description change should enable the button
        descriptionTextView.text = "On the Xbox Series S"
        activityDetailViewController.textViewDidChange(descriptionTextView)
        rootView.layoutIfNeeded()
        XCTAssertTrue(doneButton.isEnabled)
        
        // Restoring the description back to its original value should disable the button
        descriptionTextView.text = "On the Xbox Series X"
        activityDetailViewController.textViewDidChange(descriptionTextView)
        rootView.layoutIfNeeded()
        XCTAssertFalse(doneButton.isEnabled)
    }
    
    func test_saveNameChange_shouldDisplayConfirmationMessage_and_saveChanges() {
        // Enter editing mode
        activityDetailViewController.setEditing(true, animated: false)
        
        // Simulate user input
        let nameField = (activityDetailViewController.view as! ActivityDetailRootView).nameField
        _ = activityDetailViewController.textField(
            nameField,
            shouldChangeCharactersIn: NSMakeRange(0, 20),
            replacementString: "Play Forza Motorsport"
        )

        // Tap on the "Done" button
        activityDetailViewController.setEditing(false, animated: false)
        
        // Expect "Confirmation" alert controller to be presented
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController != nil"),
            evaluatedWith: activityDetailViewController
        ) { [unowned self] in
            guard
                let alert = activityDetailViewController.presentedViewController
                    as? UIAlertController
            else {
                return false
            }
            XCTAssert(alert.title == "Confirmation")
            XCTAssert(alert.message == "Are you sure?")
            return true
        }
        waitForExpectations(timeout: timeout)
        
        // Tap "Yes" button on the "Confirmation" alert controller
        guard
            let alert = activityDetailViewController.presentedViewController as? UIAlertController
        else {
            XCTFail("Expected \"Confirmation\" alert controller to be presented; but it was not.")
            return
        }
        alert.tapButton(atIndex: 0)
        
        // Expect `ActivityDetailViewController` to be dismissed
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController == nil"),
            evaluatedWith: mainViewController
        )
        waitForExpectations(timeout: timeout)
        
        // Verify the name change was saved successfully
        XCTAssert(activityRepository.activitiesCount == 5)
        guard let changedActivity = activityRepository.activity(fromIdentifier: uuid1) else {
            XCTFail("Expected the recently changed activity to be found in the repository; but it was not.")
            return
        }
        XCTAssert(changedActivity.name == "Play Forza Motorsport")
        XCTAssert(changedActivity.activityDescription == "On the Xbox Series X")
    }

    func test_saveStatusChange_shouldDisplayConfirmationMessage_and_saveChanges() {
        // Enter editing mode
        activityDetailViewController.setEditing(true, animated: false)
        
        // Simulate user input
        let doneSwitch = (activityDetailViewController.view as! ActivityDetailRootView).doneSwitch
        doneSwitch.isOn = true
        activityDetailViewController.toggleStatus(doneSwitch)
        
        // Tap on "Done" button
        activityDetailViewController.setEditing(false, animated: false)
        
        // Expect "Confirmation" alert controller to be presented
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController != nil"),
            evaluatedWith: activityDetailViewController
        ) { [unowned self] in
            guard
                let alert = activityDetailViewController.presentedViewController
                    as? UIAlertController
            else {
                return false
            }
            XCTAssert(alert.title == "Confirmation")
            XCTAssert(alert.message == "Are you sure?")
            return true
        }
        waitForExpectations(timeout: timeout)
        
        // Tap "Yes" on the "Confirmation" alert controller
        guard
            let alert = activityDetailViewController.presentedViewController as? UIAlertController
        else {
            XCTFail("Expected \"Confirmation\" alert controller to be presented; but it was not.")
            return
        }
        alert.tapButton(atIndex: 0)
        
        // Expect `ActivityDetailViewController` to be dismissed
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController == nil"),
            evaluatedWith: mainViewController
        )
        waitForExpectations(timeout: timeout)
        
        // Verify the status change was saved successfully
        XCTAssert(activityRepository.activitiesCount == 5)
        guard let changedActivity = activityRepository.activity(fromIdentifier: uuid1) else {
            XCTFail("Expected the recently changed activity to be found in the repository; but it was not.")
            return
        }
        XCTAssert(changedActivity.name == "Play Forza Horizon 5")
        XCTAssert(changedActivity.activityDescription == "On the Xbox Series X")
        XCTAssert(changedActivity.status == .done)
    }
    
    // MARK: Private
    private func constructTestingRepository() -> NSObject & ActivityRepository {
        let activityDataStore = FakeActivityDataStore()
        return ToDoListActivityRepository(dataStore: activityDataStore)
    }
    
    private func constructTestingViews(activityRepository: NSObject & ActivityRepository) throws ->
       (AppDelegate, MainViewController, ActivityDetailViewController) {
        
        func constructInitialViews() ->
           (AppDelegate, MainViewController, ActivitiesViewController) {
            
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
            return (appDelegate, mainVC, activitiesVC)
        }
        
        func presentActivityUpdateScreen() throws -> ActivityDetailViewController {
            // Simulate the user tapping on the first activity from the table...
            let indexPath = IndexPath(row: 0, section: 0)
            activitiesVC.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            activitiesVC.tableView(activitiesVC.tableView, didSelectRowAt: indexPath)
            
            let navController = try XCTUnwrap(
                activitiesVC.presentedViewController as? UINavigationController
            )
            let activityDetailVC = try XCTUnwrap(
                navController.topViewController as? ActivityDetailViewController
            )
            activityDetailVC.loadViewIfNeeded()
            activityDetailVC.view.setNeedsLayout()
            activityDetailVC.view.layoutIfNeeded()
            
            return activityDetailVC
        }
        
        let initialViews = constructInitialViews()
        let appDelegate = initialViews.0
        let mainVC = initialViews.1
        let activitiesVC = initialViews.2
        
        let activityDetailVC = try presentActivityUpdateScreen()
        
        return (appDelegate, mainVC, activityDetailVC)
    }
}
