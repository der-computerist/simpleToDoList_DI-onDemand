//
//  ActivitiesViewControllerTests.swift
//  ToDoListTests
//
//  Created by Enrique Aliaga on 11/8/22.
//

import XCTest
@testable import ToDoList

final class ActivitiesViewControllerTests: XCTestCase {
    
    // MARK: - Properties
    var activityRepository: (NSObject & ActivityRepository)!
    var appDelegate: AppDelegate!
    var mainViewController: MainViewController!
    var landingViewController: LandingViewController!
    var activitiesViewController: ActivitiesViewController!
    var expectation: XCTestExpectation?
    let timeout = 2.0
    let tableViewReloadTimeout = 5.0

    // MARK: - Methods
    override func setUp() {
        activityRepository = constructTestingRepository()
        
        let tuple = constructTestingViews(activityRepository: activityRepository)
        appDelegate = tuple.0
        mainViewController = tuple.1
        landingViewController = tuple.2
        activitiesViewController = tuple.3
    }
    
    override func tearDown() {
        activityRepository = nil
    }

    // MARK: Test Methods
    func test_startupConfiguration() {
        let viewControllers = landingViewController.children
        XCTAssert(viewControllers.first as? ActivitiesViewController === activitiesViewController)
        
        let delegate = activitiesViewController.delegate as? MainViewController
        XCTAssert(delegate === mainViewController)
        
        // State Restoration
        let restorationID = activitiesViewController.restorationIdentifier
        XCTAssert(restorationID == "ActivitiesViewController")
        
        let tableViewRestorationID = activitiesViewController.tableView.restorationIdentifier
        XCTAssert(tableViewRestorationID == "ActivitiesViewControllerTableView")
        
        // Table view delegates
        let tableViewDelegate =
            activitiesViewController.tableView.delegate as? ActivitiesViewController
        XCTAssert(tableViewDelegate === activitiesViewController)
        
        let tableViewDataSource =
            activitiesViewController.tableView.dataSource as? ActivitiesViewController
        XCTAssert(tableViewDataSource === activitiesViewController)
    }
    
    func test_tableView_layout() throws {
        let sectionsCount = activitiesViewController.tableView.numberOfSections
        XCTAssert(sectionsCount == 1)
        
        let sectionZeroRowCount = activitiesViewController.tableView.numberOfRows(inSection: 0)
        XCTAssert(sectionZeroRowCount == activityRepository.activitiesCount)
        
        let firstCell = try XCTUnwrap(
            activitiesViewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        )
        XCTAssert(firstCell.textLabel?.text == "Play Forza Horizon 5")
        XCTAssert(firstCell.imageView?.image == UIImage(named: "Unchecked") )
        
        let secondCell = try XCTUnwrap(
            activitiesViewController.tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        )
        XCTAssert(secondCell.textLabel?.text == "Play Super Mario Odyssey")
        XCTAssert(secondCell.imageView?.image == UIImage(named: "Unchecked") )
        
        let thirdCell = try XCTUnwrap(
            activitiesViewController.tableView.cellForRow(at: IndexPath(row: 2, section: 0))
        )
        XCTAssert(thirdCell.textLabel?.text == "Play The Last of Us Part I")
        XCTAssert(thirdCell.imageView?.image == UIImage(named: "Unchecked") )
        
        let fourthCell = try XCTUnwrap(
            activitiesViewController.tableView.cellForRow(at: IndexPath(row: 3, section: 0))
        )
        XCTAssert(fourthCell.textLabel?.text == "Play Grand Theft Auto V")
        XCTAssert(fourthCell.imageView?.image == UIImage(named: "Checked") )
        
        let fifthCell = try XCTUnwrap(
            activitiesViewController.tableView.cellForRow(at: IndexPath(row: 4, section: 0))
        )
        XCTAssert(fifthCell.textLabel?.text == "Play Metroid Dread")
        XCTAssert(fifthCell.imageView?.image == UIImage(named: "Checked") )
    }
    
    func test_selectActivity_shouldPresentActivityUpdateScreen_withPrePopulatedFields() throws {
        let indexPath = IndexPath(row: 0, section: 0)
        // Simulate the user selecting a row...
        activitiesViewController
            .tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        activitiesViewController
            .tableView(activitiesViewController.tableView, didSelectRowAt: indexPath)

        // Verify presentation of "Activity Update" screen
        XCTAssertNil(activitiesViewController.tableView.indexPathsForSelectedRows)
        let navController = try XCTUnwrap(
            activitiesViewController.presentedViewController as? UINavigationController
        )
        let activityDetailVC = try XCTUnwrap(
            navController.topViewController as? ActivityDetailViewController
        )
        XCTAssert(activityDetailVC.navigationItem.title == "Details")

        // Verify initial state of input fields
        let activityDetailRootView = activityDetailVC.view as! ActivityDetailRootView
        XCTAssert(activityDetailRootView.nameField.text == "Play Forza Horizon 5")
        XCTAssert(activityDetailRootView.descriptionTextView.text == "On the Xbox Series X")
        XCTAssertFalse(activityDetailRootView.doneSwitch.isOn)
        
        activitiesViewController.dismiss(animated: false, completion: nil)
    }
    
    func test_deleteRow_shouldDeleteActivity() {
        // Confirm activity exists before
        XCTAssertNotNil(activityRepository.activity(fromIdentifier: uuid3))
        
        // Delete the row corresponding to the activity
        activitiesViewController.tableView(
            activitiesViewController.tableView,
            commit: .delete,
            forRowAt: IndexPath(row: 2, section: 0)
        )
        
        // Assert activity is gone afterwards
        XCTAssertNil(activityRepository.activity(fromIdentifier: uuid3))
    }
    
    func test_modelObservation() {
        // Test insertion
        var activity6 = Activity(name: "Play Uncharted: Drake's Fortune",
                                 description: "On the PlayStation 5",
                                 status: .pending,
                                 id: UUID().uuidString,
                                 dateCreated: Date())
        activityRepository.update(activity: activity6)

        expectation = expectation(description: "Table view reloads data")
        DispatchQueue.main.asyncAfter(deadline: .now() + tableViewReloadTimeout) {
            defer { self.expectation?.fulfill() }
            
            guard let tableView = self.activitiesViewController.tableView else {
                XCTFail("Expected a table view, but found nil.")
                return
            }
            let sectionZeroRowCount = tableView.numberOfRows(inSection: 0)
            XCTAssert(sectionZeroRowCount == 6)
            let sixthCell = tableView.cellForRow(at: IndexPath(row: 5, section: 0))
            XCTAssert(sixthCell?.textLabel?.text == "Play Uncharted: Drake's Fortune")
            XCTAssert(sixthCell?.imageView?.image == UIImage(named: "Unchecked"))
        }
        waitForExpectations(timeout: tableViewReloadTimeout * 2)

        // Test replacement
        activity6 = Activity(name: "Play Uncharted 2: Among Thieves",
                             description: activity6.activityDescription,
                             status: activity6.status,
                             id: activity6.id,
                             dateCreated: activity6.dateCreated)
        activityRepository.update(activity: activity6)

        expectation = expectation(description: "Table view reloads data")
        DispatchQueue.main.asyncAfter(deadline: .now() + tableViewReloadTimeout) {
            defer { self.expectation?.fulfill() }
            
            guard let tableView = self.activitiesViewController.tableView else {
                XCTFail("Expected a table view, but found nil.")
                return
            }
            let sectionZeroRowCount = tableView.numberOfRows(inSection: 0)
            XCTAssert(sectionZeroRowCount == 6)
            let sixthCell = tableView.cellForRow(at: IndexPath(row: 5, section: 0))
            XCTAssert(sixthCell?.textLabel?.text == "Play Uncharted 2: Among Thieves")
            XCTAssert(sixthCell?.imageView?.image == UIImage(named: "Unchecked"))
        }
        waitForExpectations(timeout: tableViewReloadTimeout * 2)
        
        // Test removal
        activityRepository.delete(activity: activity6)

        expectation = expectation(description: "Table view deletes row")
        DispatchQueue.main.async {
            defer { self.expectation?.fulfill() }
            
            guard let tableView = self.activitiesViewController.tableView else {
                XCTFail("Expected a table view, but found nil.")
                return
            }
            let sectionZeroRowCount = tableView.numberOfRows(inSection: 0)
            XCTAssert(sectionZeroRowCount == 5)
        }
        waitForExpectations(timeout: timeout)
    }
    
    // MARK: Private
    private func constructTestingRepository() -> NSObject & ActivityRepository {
        let activityDataStore = FakeActivityDataStore()
        return ToDoListActivityRepository(dataStore: activityDataStore)
    }
    
    private func constructTestingViews(activityRepository: NSObject & ActivityRepository) ->
       (AppDelegate, MainViewController, LandingViewController, ActivitiesViewController) {
        
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
        return (appDelegate, mainVC, landingVC, activitiesVC)
    }
}
