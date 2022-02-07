//
//  UIAlertController+BugFix.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 2/6/22.
//

import UIKit

/*
 This is a workaround to avoid an 'unsatisfiable constraints' issue that happens when
 using a UIAlertController in 'actionSheet' style. This is a bug on UIKit, and causes
 the undesired effect of polluting the logs.
 
 Use it like this: After all addActions(...), just before calling present(...).
   alertController.pruneNegativeWidthConstraints()
*/

extension UIAlertController {
    
    public func pruneNegativeWidthConstraints() {
        for subView in view.subviews {
            for constraint in subView.constraints
                           where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
