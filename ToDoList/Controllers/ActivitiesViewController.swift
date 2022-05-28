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
    func activitiesViewController(
        _ viewController: ActivitiesViewController,
        didDeleteActivity activity: Activity
    )
}

public final class ActivitiesViewController: NiblessTableViewController {
    
    // MARK: - Properties
    public weak var delegate: ActivitiesViewControllerDelegate?
    private var allActivities: [Activity] {
        GlobalToDoListActivityRepository.allActivities
    }
    private let cellIdentifier = "UITableViewCell"
    
    // MARK: - Methods
    public init() {
        super.init(style: .plain)
    }
    
    public func refreshUI() {
        tableView.reloadData()
    }
    
    // MARK: View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
}

// MARK: - UITableViewDataSource
extension ActivitiesViewController {
    
    public override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        allActivities.count
    }

    public override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let activity = allActivities[indexPath.row]
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
            let activity = allActivities[indexPath.row]
            
            // Remove the activity from the store
            GlobalToDoListActivityRepository.delete(activity: activity) { activity in
                
                // Remove that row from the table view with an animation
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.delegate?.activitiesViewController(self, didDeleteActivity: activity)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ActivitiesViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedActivity = allActivities[indexPath.row]
        delegate?.activitiesViewController(self, didSelectActivity: selectedActivity)
    }
}
