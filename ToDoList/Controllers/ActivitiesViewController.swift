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
    
    // MARK: - Type properties
    static let viewControllerIdentifier = String(describing: ActivitiesViewController.self)
    static let tableViewIdentifier = viewControllerIdentifier + "TableView"
    
    // MARK: - Instance properties
    public weak var delegate: ActivitiesViewControllerDelegate?
    private var activities: [Activity] {
        GlobalToDoListActivityRepository.activities
    }
    private let cellIdentifier = "UITableViewCell"
    private var observation: NSKeyValueObservation?
    
    // MARK: - Methods
    public init() {
        super.init(style: .plain)
        restorationIdentifier = Self.viewControllerIdentifier
    }
    
    // MARK: View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.restorationIdentifier = Self.tableViewIdentifier
        observation = observeActivities(on: GlobalToDoListActivityRepository)
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
            cell.imageView?.image = UIImage(named: "Unchecked")
        case .done:
            cell.imageView?.image = UIImage(named: "Checked")
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
            GlobalToDoListActivityRepository.delete(activity: activity, completion: nil)
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

// MARK: - State restoration
extension ActivitiesViewController {
    
    public override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    public override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
}
