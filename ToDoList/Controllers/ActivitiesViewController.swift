//
//  ActivitiesViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

public protocol ActivitiesViewControllerDelegate: AnyObject {
    
    func activitiesViewController(
        _ viewController: ActivitiesViewController,
        didSelectActivity activity: Activity
    )
}

public final class ActivitiesViewController: NiblessTableViewController {
    
    // MARK: - Properties
    public weak var delegate: ActivitiesViewControllerDelegate?
    
    private let activityRepository: NSObject & ActivityRepository
    private var activities: [Activity] { activityRepository.activities }
    private let cellIdentifier = Constants.cellReuseIdentifier
    private var observation: NSKeyValueObservation?
    
    // MARK: - Methods
    public init(activityRepository: NSObject & ActivityRepository) {
        self.activityRepository = activityRepository
        super.init(style: .plain)
        restorationIdentifier = StateRestoration.viewControllerIdentifier
    }
    
    // MARK: View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self  // For some reason, this is needed for
                                     // `UIDataSourceModelAssociation` methods to be called.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.restorationIdentifier = StateRestoration.tableViewIdentifier
        observation = observeActivities(on: activityRepository)
    }
    
    // MARK: Private
    private func observeActivities<T: NSObject & ActivityRepository>(
        on subject: T
    ) -> NSKeyValueObservation {
        
        subject.observe(\.activities, options: .new) { [weak self] _, change in
            switch change.kind {
            case .removal:
                guard let oldIndex = change.indexes?.first else { return }
                let indexPaths = [IndexPath(row: oldIndex, section: 0)]
                DispatchQueue.main.async {
                    self?.tableView.deleteRows(at: indexPaths, with: .automatic)
                }
            default:
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ActivitiesViewController {
    
    public override func tableView(_ _: UITableView, numberOfRowsInSection _: Int) -> Int {
        activities.count
    }

    public override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let activity = activities[indexPath.row]
        cell.textLabel?.text = activity.name

        switch activity.status {
        case .pending:
            cell.imageView?.image = Assets.pendingActivityImage
        case .done:
            cell.imageView?.image = Assets.doneActivityImage
        }
        
        return cell
    }
    
    public override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let activity = activities[indexPath.row]
            activityRepository.delete(activity: activity)
        }
    }
}

// MARK: - UITableViewDelegate
extension ActivitiesViewController {
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedActivity = activities[indexPath.row]
        delegate?.activitiesViewController(self, didSelectActivity: selectedActivity)
    }
}

// MARK: - State Restoration
extension ActivitiesViewController: UIDataSourceModelAssociation {
    
    public func modelIdentifierForElement(at idx: IndexPath, in view: UIView) -> String? {
        activities[idx.row].id
    }
    
    public func indexPathForElement(
        withModelIdentifier identifier: String,
        in view: UIView
    ) -> IndexPath? {
        
        guard let activity = activityRepository.activity(fromIdentifier: identifier),
              let index = activities.firstIndex(of: activity) else {
            return nil
        }
        return IndexPath(row: index, section: 0)
    }
}

// MARK: - Constants
extension ActivitiesViewController {
    
    struct Assets {
        static let doneActivityImage      = UIImage(named: "Checked")
        static let pendingActivityImage   = UIImage(named: "Unchecked")
    }
    
    struct Constants {
        static let cellReuseIdentifier = "UITableViewCell"
    }
    
    struct StateRestoration {
        static let viewControllerIdentifier   = String(describing: ActivitiesViewController.self)
        static let tableViewIdentifier        = viewControllerIdentifier + "TableView"
    }
}
