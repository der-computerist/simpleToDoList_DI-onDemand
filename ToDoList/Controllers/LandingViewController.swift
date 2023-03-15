//
//  LandingViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/24/22.
//

import UIKit

public protocol LandingViewControllerDelegate: AnyObject {
    
    func landingViewControllerAddButtonWasTapped(_ viewController: LandingViewController)
}

public final class LandingViewController: NiblessViewController {
    
    // MARK: - Properties
    public weak var delegate: LandingViewControllerDelegate?
    
    private let activitiesViewController: ActivitiesViewController
    private let activityRepository: NSObject & ActivityRepository
    private var observation: NSKeyValueObservation?

    private var rootView: LandingRootView! {
        guard isViewLoaded else { return nil }
        return (view as! LandingRootView)
    }
    
    private lazy var addButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(handleAddButtonPressed(sender:))
        )
        return buttonItem
    }()
    
    // MARK: - Methods
    public init(
        activitiesViewController: ActivitiesViewController,
        activityRepository: NSObject & ActivityRepository
    ) {
        self.activitiesViewController = activitiesViewController
        self.activityRepository = activityRepository
        
        super.init()
        
        restorationIdentifier = StateRestoration.viewControllerIdentifier
        navigationItem.title = Constants.title
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    // MARK: View lifecycle
    public override func loadView() {
        view = LandingRootView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        add(childViewController: activitiesViewController, over: rootView.activitiesContainerView)
        observation = observeActivitiesCount(on: activityRepository)
    }
    
    // MARK: Actions
    @objc
    func handleAddButtonPressed(sender: UIBarButtonItem) {
        delegate?.landingViewControllerAddButtonWasTapped(self)
    }
    
    @objc
    public override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        activitiesViewController.setEditing(editing, animated: animated)
    }
    
    // MARK: Private
    private func observeActivitiesCount<T: NSObject & ActivityRepository>(
        on subject: T
    ) -> NSKeyValueObservation {
        
        subject.observe(\.activitiesCount, options: [.initial, .new]) { [weak self] subject, _ in
            DispatchQueue.main.async {
                self?.updateActivitiesCountLabel(with: subject.activitiesCount)
            }
        }
    }
    
    private func updateActivitiesCountLabel(with newActivitiesCount: Int) {
        rootView.activitiesCountLabel.text = "Total: \(newActivitiesCount)"
    }
}

// MARK: - State Restoration
extension LandingViewController {
    
    public override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(activitiesViewController,
            forKey: StateRestoration.Keys.activitiesViewController)
        coder.encode(isEditing, forKey: StateRestoration.Keys.landingViewControllerIsEditing)
    }
    
    public override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        isEditing = coder.decodeBool(forKey: StateRestoration.Keys.landingViewControllerIsEditing)
    }
}

// MARK: - Constants
extension LandingViewController {
    
    struct Constants {
        static let title = "To Do List"
    }
    
    struct StateRestoration {
        static let viewControllerIdentifier = String(describing: LandingViewController.self)
        
        struct Keys {
            static let activitiesViewController         = "activitiesViewController"
            static let landingViewControllerIsEditing   = "landingViewControllerIsEditing"
        }
    }
}
