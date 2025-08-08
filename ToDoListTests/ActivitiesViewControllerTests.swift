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
        // Wait for the table view to do its first layout pass.
        expectation = expectation(description: "Table view did perform initial layout")
        
        DispatchQueue.main.async {
            self.activitiesViewController.tableView.layoutIfNeeded()
            self.expectation?.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
        
        // Test table view layout
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
        
        // Dismiss presented screen
        expectation = expectation(description: "Activity Update screen dismissed")
        
        DispatchQueue.main.async {
            self.activitiesViewController.dismiss(animated: false) { [unowned self] in
                self.expectation?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_deleteRow_shouldDeleteActivity() {
        // Disable model observation
        activitiesViewController.invalidateObservation()
        
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
    
    func test_modelObservation() throws {
        // Replace the table view with a spy
        let spyTableView = ReloadDetectingTableView(frame: .zero, style: .plain)
        spyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        spyTableView.didReload = { self.expectation?.fulfill() }
        spyTableView.didDeleteRows = { self.expectation?.fulfill() }

        activitiesViewController.tableView = spyTableView
        activitiesViewController.loadViewIfNeeded()
        
        let tableView = try XCTUnwrap(
            self.activitiesViewController.tableView, "Expected a table view, but found none"
        )
        var newCell: UITableViewCell?
        
        //===---------------------------------------------------------------------------------===//
        //  Test insertion
        //===---------------------------------------------------------------------------------===//
        // Insert activity
        var activity6 = Activity(
            name: "Play Uncharted: Drake's Fortune",
            description: "On the PlayStation 5",
            status: .pending,
            id: UUID().uuidString,
            dateCreated: Date()
        )
        activityRepository.update(activity: activity6)

        // Wait for the table view to reload
        expectation = expectation(description: "Table view did reload")
        waitForExpectations(timeout: timeout)
        
        // Execute assertions
        expectation = expectation(description: "Async assertions executed")
        
        DispatchQueue.main.async {
            let newCellIdx = IndexPath(row: 5, section: 0)
            newCell = tableView.dataSource?.tableView(tableView, cellForRowAt: newCellIdx)
            XCTAssert(tableView.numberOfRows(inSection: 0) == 6)
            XCTAssert(newCell?.textLabel?.text == "Play Uncharted: Drake's Fortune")
            XCTAssert(newCell?.imageView?.image == UIImage(named: "Unchecked"))
            
            self.expectation?.fulfill()
        }
        
        waitForExpectations(timeout: timeout)

        //===---------------------------------------------------------------------------------===//
        //  Test replacement
        //===---------------------------------------------------------------------------------===//
        // Replace activity
        activity6 = Activity(
            name: "Play Uncharted 2: Among Thieves",
            description: activity6.activityDescription,
            status: activity6.status,
            id: activity6.id,
            dateCreated: activity6.dateCreated
        )
        activityRepository.update(activity: activity6)
        
        // Wait for the table view to reload
        expectation = expectation(description: "Table view did reload")
        waitForExpectations(timeout: timeout)

        // Execute assertions
        expectation = expectation(description: "Async assertions executed")
        
        DispatchQueue.main.async {
            let newCellIdx = IndexPath(row: 5, section: 0)
            newCell = tableView.dataSource?.tableView(tableView, cellForRowAt: newCellIdx)
            XCTAssert(tableView.numberOfRows(inSection: 0) == 6)
            XCTAssert(newCell?.textLabel?.text == "Play Uncharted 2: Among Thieves")
            XCTAssert(newCell?.imageView?.image == UIImage(named: "Unchecked"))
            
            self.expectation?.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
        
        //===---------------------------------------------------------------------------------===//
        //  Test removal
        //===---------------------------------------------------------------------------------===//
        // Remove activity
        activityRepository.delete(activity: activity6)

        // Wait for the table view to delete the row
        expectation = expectation(description: "Table view did delete row")
        waitForExpectations(timeout: timeout)
        
        // Execute assertions
        let rowCount = tableView.numberOfRows(inSection: 0)
        XCTAssert(rowCount == 5)
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

// MARK: - Supporting types
/// A `UITableView` subclass meant specifically for testing.
///
/// It allows us to run tests _after_ the table view has finished refreshing its UI.
final class ReloadDetectingTableView: UITableView {
    /// A closure to be called once the table view has finished reloading.
    var didReload: (() -> Void)?
    /// A closure to be called once the table view has finished deleting rows.
    var didDeleteRows: (() -> Void)?
    /// Number of times `reloadData()` has been called.
    private var reloadCount = 0
    
    override func reloadData() {
        super.reloadData()
        
        // Ignore the first call, which is a false positive invoked
        // as part of loading the table view for the first time.
        reloadCount += 1
        if reloadCount > 1 {
            didReload?()
        }
    }
    
    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        super.deleteRows(at: indexPaths, with: animation)
        didDeleteRows?()
    }
}
