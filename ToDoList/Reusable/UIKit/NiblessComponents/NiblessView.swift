//
//  NiblessView.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

open class NiblessView: UIView {
    
    public override init(frame: CGRect) {
      super.init(frame: frame)
    }
  
    @available(*, unavailable,
        message: """
        Loading this view from a nib is unsupported in favor of initializer dependency injection.
        """
    )
    public required init?(coder: NSCoder) {
        fatalError("""
        Loading this view from a nib is unsupported in favor of initializer dependency injection.
        """)
    }
}
