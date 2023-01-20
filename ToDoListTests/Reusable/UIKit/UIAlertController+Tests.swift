//
//  UIAlerController+Tests.swift
//  ToDoListTests
//
//  Created by Enrique Aliaga on 1/17/23.
//

import UIKit

/*
 The method added by this extension allows us to programmatically choose an action from a
 `UIAlertController` when it is presented to the user. It is used for testing only.
 */
extension UIAlertController {
    
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void
    
    public func tapButton(atIndex index: Int) {
        guard let block = actions[index].value(forKey: "handler") else { return }
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(actions[index])
    }
}
