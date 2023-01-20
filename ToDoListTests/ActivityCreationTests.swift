//
//  ActivityCreationTests.swift
//  ToDoListTests
//
//  Created by Enrique Aliaga on 11/8/22.
//

import XCTest
@testable import ToDoList

final class ActivityCreationTests: XCTestCase {

    // MARK: - Properties
    var activityRepository: (NSObject & ActivityRepository)!
    var appDelegate: AppDelegate!
    var mainViewController: MainViewController!
    var activityDetailViewController: ActivityDetailViewController!
    var expectation: XCTestExpectation?
    let timeout = 3.0
    
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
        XCTAssert(navigationItemTitle == "New Activity")
        
        // "Cancel" button item
        let navigationItemLeftButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.leftBarButtonItem
        )
        XCTAssert(navigationItemLeftButton.target === activityDetailViewController)
        XCTAssert(navigationItemLeftButton.action ==
                #selector(ActivityDetailViewController.handleCancelPressed(sender:)))
        
        // "Add" button item
        let navigationItemRightButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.rightBarButtonItem
        )
        XCTAssert(navigationItemRightButton.title == "Add")
        XCTAssert(navigationItemRightButton.target === activityDetailViewController)
        XCTAssert(navigationItemRightButton.action ==
                #selector(ActivityDetailViewController.handleSavePressed(sender:)))
        XCTAssertFalse(navigationItemRightButton.isEnabled)
        
        // Validate input fields
        let rootView = activityDetailViewController.view as! ActivityDetailRootView
        let nameField = rootView.nameField
        let descriptionTextView = rootView.descriptionTextView
        let statusSection = rootView.statusStackView
        
        XCTAssertTrue(nameField.isEnabled)
        XCTAssertTrue(descriptionTextView.isUserInteractionEnabled)
        XCTAssertTrue(statusSection.isHidden)
    }
    
    func test_addButtonActivation() throws {
        let rootView = activityDetailViewController.view as! ActivityDetailRootView
        let nameField = rootView.nameField
        let descriptionTextView = rootView.descriptionTextView
        let addButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.rightBarButtonItem
        )
        
        // Typing in a name should enable the "Add" button
        _ = activityDetailViewController.textField(
            nameField,
            shouldChangeCharactersIn: NSMakeRange(0, 0),
            replacementString: "A"
        )
        activityDetailViewController.view.layoutIfNeeded()
        XCTAssertTrue(addButton.isEnabled)
        
        // Clearing the name field should disable the "Add" button
        _ = activityDetailViewController.textField(
            nameField,
            shouldChangeCharactersIn: NSMakeRange(0, 0),
            replacementString: ""
        )
        activityDetailViewController.view.layoutIfNeeded()
        XCTAssertFalse(addButton.isEnabled)
        
        // Typing in a description should have no effect on the "Add" button
        descriptionTextView.text = "Something in the way she moves..."
        activityDetailViewController.textViewDidChange(descriptionTextView)
        activityDetailViewController.view.layoutIfNeeded()
        XCTAssertFalse(addButton.isEnabled)
    }
    
    func test_saveNewActivity_withCorrectNameAndDescription_shouldDisplayConfirmationMessage_and_registerNewActivity() throws {
        // Simulate user input: name and description
        let rootView = activityDetailViewController.view as! ActivityDetailRootView
        let nameField = rootView.nameField
        let descriptionTextView = rootView.descriptionTextView
        
        _ = activityDetailViewController.textField(
            nameField,
            shouldChangeCharactersIn: NSMakeRange(0, 0),
            replacementString: "Play Uncharted: Drake's Fortune"
        )
        descriptionTextView.text = "On the PlayStation 5"
        activityDetailViewController.textViewDidChange(descriptionTextView)

        // Expect "Confirmation" alert controller to be presented once user taps
        // on the "Add" button.
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController != nil"),
            evaluatedWith: activityDetailViewController
        ) { [weak self] in
            guard
                let alert = self?.activityDetailViewController.presentedViewController
                    as? UIAlertController
            else {
                return false
            }
            XCTAssert(alert.title == "Confirmation")
            XCTAssert(alert.message == "Are you sure?")
            return true
        }

        // Tap on "Add" button
        let addButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.rightBarButtonItem
        )
        activityDetailViewController.handleSavePressed(sender: addButton)
        waitForExpectations(timeout: timeout)
        
        // Expect `ActivityDetailViewController` to be dismissed once the new
        // activity is registered.
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController == nil"),
            evaluatedWith: mainViewController
        )

        // Tap "Yes" button on the "Confirmation" alert controller
        guard
            let alert = activityDetailViewController.presentedViewController as? UIAlertController
        else {
            XCTFail("Expected \"Confirmation\" alert controller to be presented; but it was not.")
            return
        }
        alert.tapButton(atIndex: 0)
        waitForExpectations(timeout: timeout)
        
        // Verify the new activity has been registered successfully.
        XCTAssert(activityRepository.activitiesCount == 6)
        guard let newActivity = activityRepository.activities.last else {
            XCTFail("Expected newly created activity to be found in the repository, but it was not.")
            return
        }
        XCTAssert(newActivity.name == "Play Uncharted: Drake's Fortune")
        XCTAssert(newActivity.activityDescription == "On the PlayStation 5")
    }
    
    func test_saveNewActivity_withEmptyName_shouldDisplayErrorMessage() throws {
        // Expect error alert controller to be presented
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController != nil"),
            evaluatedWith: activityDetailViewController
        ) { [weak self] in
            guard
                let alert = self?.activityDetailViewController.presentedViewController
                    as? UIAlertController
            else {
                return false
            }
            XCTAssert(alert.title == "Activity Creation Error")
            XCTAssert(alert.message == "Activity name can't be empty.")
            return true
        }
        defer { waitForExpectations(timeout: timeout) }
        
        // Tap on "Add" button
        let addButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.rightBarButtonItem
        )
        activityDetailViewController.handleSavePressed(sender: addButton)
        
        // Verify the activity was not registered
        XCTAssert(activityRepository.activitiesCount == 5)
    }
    
    func test_saveNewActivity_withNameTooLong_shouldDisplayErrorMessage() throws {
        // Simulate user input
        let nameField = (activityDetailViewController.view as! ActivityDetailRootView).nameField
        _ = activityDetailViewController.textField(
            nameField,
            shouldChangeCharactersIn: NSMakeRange(0, 0),
            replacementString: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
        )

        // Expect error alert controller to be presented
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController != nil"),
            evaluatedWith: activityDetailViewController
        ) { [weak self] in
            guard
                let alert = self?.activityDetailViewController.presentedViewController
                    as? UIAlertController
            else {
                return false
            }
            XCTAssert(alert.title == "Activity Creation Error")
            XCTAssert(alert.message == "Activity name exceeds max characters (50).")
            return true
        }
        defer { waitForExpectations(timeout: timeout) }
        
        // Tap on "Add" button
        let addButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.rightBarButtonItem
        )
        activityDetailViewController.handleSavePressed(sender: addButton)
    }
    
    func test_saveNewActivity_withDescriptionTooLong_shouldDisplayErrorMessage() throws {
        // Simulate user input
        let rootView = activityDetailViewController.view as! ActivityDetailRootView
        let nameField = rootView.nameField
        let descriptionTextView = rootView.descriptionTextView
        
        _ = activityDetailViewController.textField(
            nameField,
            shouldChangeCharactersIn: NSMakeRange(0, 0),
            replacementString: "Play Uncharted: Drake's Fortune"
        )
        descriptionTextView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed molestie accumsan turpis sit amet suscipit. Phasellus ut facilisis elit, ut tristique quam. Maecenas maximus lobortis cursus. Nulla at nunc."
        activityDetailViewController.textViewDidChange(descriptionTextView)

        // Expect error alert controller to be presented
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController != nil"),
            evaluatedWith: activityDetailViewController
        ) { [weak self] in
            guard
                let alert = self?.activityDetailViewController.presentedViewController
                    as? UIAlertController
            else {
                return false
            }
            XCTAssert(alert.title == "Activity Creation Error")
            XCTAssert(alert.message == "Activity description exceeds max characters (200).")
            return true
        }
        defer { waitForExpectations(timeout: timeout) }
        
        // Tap on "Add" button
        let addButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.rightBarButtonItem
        )
        activityDetailViewController.handleSavePressed(sender: addButton)
    }
    
    func test_cancel_withoutUnsavedChanges_shouldDismissView() throws {
        // Expect `ActivityDetailViewController` to be dismissed
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController == nil"),
            evaluatedWith: mainViewController
        )
        defer { waitForExpectations(timeout: timeout) }

        // Tap on "Cancel" button
        let cancelButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.leftBarButtonItem
        )
        activityDetailViewController.handleCancelPressed(sender: cancelButton)
    }
    
    func test_cancel_withUnsavedChanges_shouldDisplayConfirmationMessage() throws {
        // Simulate user input: a single letter "A" on the name field
        let nameField = (activityDetailViewController.view as! ActivityDetailRootView).nameField
        _ = activityDetailViewController.textField(
            nameField,
            shouldChangeCharactersIn: NSMakeRange(0, 0),
            replacementString: "A"
        )
        
        // Expect "Confirmation" alert controller to be presented
        expectation = expectation(
            for: NSPredicate(format: "presentedViewController != nil"),
            evaluatedWith: activityDetailViewController
        ) { [weak self] in
            guard
                let alert = self?.activityDetailViewController.presentedViewController
                    as? UIAlertController
            else {
                return false
            }
            XCTAssert(alert.actions[0].title == "Discard Changes")
            XCTAssert(alert.actions[1].title == "Cancel")
            return true
        }
        defer { waitForExpectations(timeout: timeout) }
        
        // Tap on "Cancel" button
        let cancelButton = try XCTUnwrap(
            activityDetailViewController.navigationItem.leftBarButtonItem
        )
        activityDetailViewController.handleCancelPressed(sender: cancelButton)
    }
    
    // MARK: Private
    private func constructTestingRepository() -> NSObject & ActivityRepository {
        let activityDataStore = FakeActivityDataStore()
        return ToDoListActivityRepository(dataStore: activityDataStore)
    }
    
    private func constructTestingViews(activityRepository: NSObject & ActivityRepository) throws ->
       (AppDelegate, MainViewController, ActivityDetailViewController) {
        
        func constructInitialViews() -> (AppDelegate, MainViewController, LandingViewController) {
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
        
        func presentActivityCreationScreen() throws -> ActivityDetailViewController {
            let addButton = try XCTUnwrap(landingVC.navigationItem.rightBarButtonItem)
            
            landingVC.handleAddButtonPressed(sender: addButton)
            
            let navController = try XCTUnwrap(
                landingVC.presentedViewController as? UINavigationController
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
        let landingVC = initialViews.2
        
        let activityDetailVC = try presentActivityCreationScreen()
        
        return (appDelegate, mainVC, activityDetailVC)
    }
}
