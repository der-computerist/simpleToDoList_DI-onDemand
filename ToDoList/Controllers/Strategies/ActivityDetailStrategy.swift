//
//  ActivityDetailStrategy.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 4/5/23.
//

import UIKit

public protocol ActivityDetailStrategy: AnyObject {
    
    var title: String { get }

    var rightBarButtonItem: UIBarButtonItem { get }
    
    func enableOrDisableRightBarButtonItem()
    func prepareForPresentation()
    
    func hidesActivityStatus() -> Bool
    func enablesNameField() -> Bool
    func enablesDescriptionField() -> Bool
}
