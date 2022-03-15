//
//  ActivitiesViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

final class ActivitiesViewController: NiblessTableViewController {
    
    // MARK: - Properties
    var onDelete: (() -> Void)?
    
    // MARK: - Methods
    public init() {
        super.init(style: .plain)
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        GlobalToDoListActivityRepository.allActivities.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let activity = GlobalToDoListActivityRepository.allActivities[indexPath.row]
        cell.textLabel?.text = activity.name

        switch activity.status {
        case .pending:
            cell.imageView?.image = UIImage(named: "Unchecked")
        case .done:
            cell.imageView?.image = UIImage(named: "Checked")
        }
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let activity = GlobalToDoListActivityRepository.allActivities[indexPath.row]
            
            // Remove the activity from the store
            GlobalToDoListActivityRepository.delete(activity: activity) { _ in
                self.onDelete?()
            }
            
            // Remove that row from the table view with an animation
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let activities = GlobalToDoListActivityRepository.allActivities
        let selectedActivity = activities[indexPath.row]
        
        let detailViewController = ActivityDetailViewController(
            for: .existingActivity(selectedActivity)
        )
        detailViewController.onSave = {
            self.tableView.reloadData()
        }
        detailViewController.delegate = self
        
        let navController = NiblessNavigationController(rootViewController: detailViewController)
        navController.presentationController?.delegate = detailViewController

        present(navController, animated: true)
    }
}

extension ActivitiesViewController: ActivityDetailViewControllerDelegate {
    
    func activityDetailViewControllerDidCancel(
        _ activityDetailViewController: ActivityDetailViewController
    ) {
        dismiss(animated: true)
    }
    
    func activityDetailViewControllerDidFinish(
        _ activityDetailViewController: ActivityDetailViewController
    ) {
        dismiss(animated: true)
    }
}
