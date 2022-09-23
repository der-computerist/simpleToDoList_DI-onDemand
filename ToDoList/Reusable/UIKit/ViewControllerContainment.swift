//
//  ViewControllerContainment.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/24/22.
//

import UIKit

extension UIViewController {
    
    // MARK: - Methods
    public func add(
        childViewController child: UIViewController,
        over containingView: UIView
    ) {
        guard child.parent == nil else { return }

        addChild(child)
        containingView.addSubview(child.view)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            containingView.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
            containingView.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
            containingView.topAnchor.constraint(equalTo: child.view.topAnchor),
            containingView.bottomAnchor.constraint(equalTo: child.view.bottomAnchor)
        ]
        constraints.forEach { $0.isActive = true }
        containingView.addConstraints(constraints)
        
        child.didMove(toParent: self)
    }
    
    public func remove(childViewController child: UIViewController?) {
        guard let child = child else { return }
        guard child.parent != nil else { return }
        
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
