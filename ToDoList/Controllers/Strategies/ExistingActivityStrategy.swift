//
//  ExistingActivityStrategy.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 4/5/23.
//

import UIKit

public class ExistingActivityStrategy: ActivityDetailStrategy {

    // MARK: - Properties
    public let title = Constants.title
    public lazy var rightBarButtonItem = owningViewController.editButtonItem
    private unowned let owningViewController: ActivityDetailViewController

    // MARK: - Methods
    public init(for owningViewController: ActivityDetailViewController) {
        self.owningViewController = owningViewController
    }
    
    public func enableOrDisableRightBarButtonItem() {
        /*
         - While out of editing mode, the "Edit/Done" button item always remains enabled.
         - After entering editing mode, the "Edit/Done" button will remain disabled as long
           as there are no edits. As soon as edits are made, it will become enabled. It will
           disable itself again if the activity name becomes empty.
         */
        let isInEditingMode = owningViewController.isEditing
        let activityBuilder = owningViewController.activityBuilder
        
        rightBarButtonItem.isEnabled =
            !isInEditingMode || (activityBuilder.hasChanges() != activityBuilder.name.isEmpty)
    }
    
    public func prepareForPresentation() {
        // If state restoration occurred, restore the editing state of the view controller.
        let wasEditing = owningViewController.wasEditing
        if wasEditing {
            owningViewController.isEditing = wasEditing
        }
    }
    
    public func hidesActivityStatus() -> Bool {
        false
    }
    
    public func enablesNameField() -> Bool {
        false
    }
    
    public func enablesDescriptionField() -> Bool {
        false
    }
}

extension ExistingActivityStrategy {
    
    struct Constants {
        static let title = "Detail"
    }
}
