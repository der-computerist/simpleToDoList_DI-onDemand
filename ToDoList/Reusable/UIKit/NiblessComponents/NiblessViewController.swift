//
//  NiblessViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

open class NiblessViewController: UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
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
