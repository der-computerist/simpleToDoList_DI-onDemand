//
//  ActivitiesViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

final class ActivitiesViewController: NiblessTableViewController {
    
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
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let activities = GlobalToDoListActivityRepository.allActivities
        let selectedActivity = activities[indexPath.row]
        
        let detailViewController = ActivityDetailViewController(
            for: .existingActivity(activity: selectedActivity)
        )
        let navController = NiblessNavigationController(
            rootViewController: detailViewController
        )
        
        present(navController, animated: true)
    }
}
