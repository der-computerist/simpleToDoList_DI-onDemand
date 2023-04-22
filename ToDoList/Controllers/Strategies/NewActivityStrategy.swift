//
//  NewActivityStrategy.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 4/5/23.
//

import UIKit

public class NewActivityStrategy: ActivityDetailStrategy {

    // MARK: - Properties
    public let title = Constants.title

    public lazy var rightBarButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            title: Constants.saveButtonItemTitle,
            style: .done,
            target: owningViewController,
            action: #selector(ActivityDetailViewController.handleSavePressed(sender:))
        )
        return buttonItem
    }()
    
    private unowned let owningViewController: ActivityDetailViewController

    // MARK: - Methods
    public init(for owningViewController: ActivityDetailViewController) {
        self.owningViewController = owningViewController
    }
    
    public func enableOrDisableRightBarButtonItem() {
        // If there are unsaved changes to the activity name, enable the Save button.
        rightBarButtonItem.isEnabled = owningViewController.activityBuilder.hasNameChanges()
    }
    
    public func prepareForPresentation() {
        // When creating a new activity, present the keyboard as soon as the view
        // begins to appear.
        owningViewController.showKeyboard()
    }
    
    public func hidesActivityStatus() -> Bool {
        true
    }
    
    public func enablesNameField() -> Bool {
        true
    }
    
    public func enablesDescriptionField() -> Bool {
        true
    }
}

extension NewActivityStrategy {
    
    struct Constants {
        static let title                 = "New Activity"
        static let saveButtonItemTitle   = "Add"
    }
}
