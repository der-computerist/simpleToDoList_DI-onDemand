//
//  NiblessTableViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/18/22.
//

import UIKit

open class NiblessTableViewController: UITableViewController {
    
    public override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    @available(*, unavailable,
        message: """
        Loading this view controller from a nib is unsupported in favor of initializer dependency \
        injection.
        """
    )
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable,
        message: """
        Loading this view controller from a nib is unsupported in favor of initializer dependency \
        injection.
        """
    )
    public required init?(coder: NSCoder) {
        fatalError("""
        Loading this view controller from a nib is unsupported in favor of initializer dependency \
        injection.
        """)
    }
}
