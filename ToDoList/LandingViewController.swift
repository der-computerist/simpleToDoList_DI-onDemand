//
//  LandingViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/24/22.
//

import UIKit

final class LandingViewController: NiblessViewController {
    
    // MARK: - Properties
    private let activitiesViewController: ActivitiesViewController
    
    private lazy var rootView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        
        // Layout margins
        var customMargins = view.layoutMargins
        customMargins.top = 16
        view.layoutMargins = customMargins
        
        return view
    }()
    
    private lazy var activitiesCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Total: 0"
        return label
    }()
    
    private lazy var activitiesContainerView: UIView = {
        UIView()
    }()
    
    // MARK: - Methods
    public init(activitiesViewController: ActivitiesViewController) {
        self.activitiesViewController = activitiesViewController
        super.init()
        
        navigationItem.title = "To Do List"
        
        let addNewActivityItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewActivity(_:))
        )
        navigationItem.rightBarButtonItem = addNewActivityItem
    }
    
    // MARK: View lifecycle
    override func loadView() {
        view = rootView
        constructViewHierarchy()
        activateConstraints()
    }
    
    override func viewDidLoad() {
        add(childViewController: activitiesViewController, over: activitiesContainerView)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateActivitiesCountLabel()
    }
    
    // MARK: Button actions
    @objc
    func addNewActivity(_ sender: UIBarButtonItem) {
        GlobalToDoListActivityRepository.createActivity() { createdActivity in
            let detailViewController = ActivityDetailViewController(
                for: .newActivity(activity: createdActivity)
            )
            detailViewController.onDismiss = { [weak self] in
                self?.activitiesViewController.tableView.reloadData()
                self?.updateActivitiesCountLabel()
            }
            let navController = NiblessNavigationController(
                rootViewController: detailViewController
            )
            navController.presentationController?.delegate = detailViewController
            
            self.present(navController, animated: true)
        }
    }
    
    // MARK: Private
    private func constructViewHierarchy() {
        view.addSubview(activitiesCountLabel)
        view.addSubview(activitiesContainerView)
    }
    
    private func activateConstraints() {
        activateConstraintsActivitiesCountLabel()
        activateConstraintsActivitiesContainerView()
    }
    
    private func activateConstraintsActivitiesCountLabel() {
        /*
         (Describe what you want the view to look like independent of screen size.)
         
         I want the `activitiesCountLabel` to be:
             * 16 points from the top of the screen
             * 16 points from the right edge of the screen
             * 8 points above the `activitiesTable`
             * as wide and as tall as its text
         ———————————————————————————————————————————
         (Turn the description into constraints.)
         
         Constraints for the `activitiesCountLabel`:
             * The label's top edge should be 16 points away from its nearest neighbor.
             * The label's right edge should be 16 points away from its nearest neighbor.
             * The label's width should be equal to the width of its text rendered at
                its font size.
             * The label's height should be equal to the height of its text rendered at
                its font size.
         ———————————————————————————————————————————
         (Express constraints in terms of anchors.)
         
         Constraints for the `activitiesCountLabel`:
             * The top anchor of the label should be 16 points away from the top anchor
                of its superview.
             * The trailing anchor of the label should be 16 points away from trailing
                anchor of its superview.
             * The width anchor of the label should be equal to the width of its text
                rendered at its font size.
             * The height anchor of the label should be equal to the height of its
                text rendered at its font size.
         */
        activitiesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.layoutMarginsGuide
        let top = activitiesCountLabel.topAnchor.constraint(equalTo: margins.topAnchor)
        let trailing = activitiesCountLabel.trailingAnchor.constraint(
            equalTo: margins.trailingAnchor
        )
        
        NSLayoutConstraint.activate([top, trailing])
    }
    
    private func activateConstraintsActivitiesContainerView() {
        activitiesContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let top = activitiesContainerView.topAnchor.constraint(
            equalTo: activitiesCountLabel.bottomAnchor,
            constant: 8
        )
        let leading = activitiesContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailing = activitiesContainerView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor
        )
        let bottom = activitiesContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([top, leading, trailing, bottom])
    }
    
    private func updateActivitiesCountLabel() {
        guard var text = activitiesCountLabel.text else {
            return
        }
        guard let indexOfSpace = text.lastIndex(of: " ") else {
            assertionFailure("The Activities count label must use a space as delimiter")
            return
        }

        let activitiesCount = GlobalToDoListActivityRepository.allActivities.count
        
        text.removeSubrange(text.index(after: indexOfSpace)...)
        text.append(String(activitiesCount))
        activitiesCountLabel.text = text
    }
}
