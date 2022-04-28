//
//  LandingViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/24/22.
//

import UIKit

public protocol LandingViewControllerDelegate: AnyObject {
    
    func landingViewControllerAddButtonWasTapped(_ landingViewController: LandingViewController)
}

public final class LandingViewController: NiblessViewController {
    
    // MARK: - Properties
    public let activitiesViewController: ActivitiesViewController
    public weak var delegate: LandingViewControllerDelegate?
    private var activitiesCount: Int {
        GlobalToDoListActivityRepository.allActivities.count
    }
    
    public var rootView: LandingRootView! {
        guard isViewLoaded else { return nil }
        return (view as! LandingRootView)
    }
    
    private lazy var addButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewActivity(_:))
        )
        return buttonItem
    }()
    
    // MARK: - Methods
    public init(activitiesViewController: ActivitiesViewController) {
        self.activitiesViewController = activitiesViewController
        super.init()
        navigationItem.title = "To Do List"
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    public func refreshUI() {
        updateActivitiesCountLabel()
        activitiesViewController.refreshUI()
    }
    
    // MARK: View lifecycle
    public override func loadView() {
        view = LandingRootView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        updateActivitiesCountLabel()
    }
    
    public override func viewWillLayoutSubviews() {
        add(childViewController: activitiesViewController, over: rootView.activitiesContainerView)
    }
    
    // MARK: Actions
    @objc
    func addNewActivity(_ sender: UIBarButtonItem) {
        delegate?.landingViewControllerAddButtonWasTapped(self)
    }
    
    @objc
    public override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        activitiesViewController.setEditing(editing, animated: animated)
    }
    
    // MARK: Private
    private func updateActivitiesCountLabel() {
        rootView.activitiesCountLabel.text = "Total: \(activitiesCount)"
    }
}
