//
//  LandingRootView.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 4/27/22.
//

import UIKit

public final class LandingRootView: NiblessView {
    
    // MARK: - Properties
    private var hierarchyNotReady = true
    
    let activitiesCountLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = AccessibilityIdentifiers.activitiesCountLabel
        return label
    }()
    
    let activitiesContainerView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = AccessibilityIdentifiers.activitiesContainerView
        return view
    }()
    
    // MARK: - Methods
    public override func didMoveToWindow() {
        guard hierarchyNotReady else {
            return
        }
        styleView()
        constructHierarchy()
        activateConstraints()
        hierarchyNotReady = false
    }
    
    // MARK: Private
    private func styleView() {
        backgroundColor = Color.background
        accessibilityIdentifier = AccessibilityIdentifiers.rootView
        
        // Layout margins
        var customMargins = layoutMargins
        customMargins.top = Metrics.largeSpacing
        layoutMargins = customMargins
    }
    
    private func constructHierarchy() {
        addSubview(activitiesCountLabel)
        addSubview(activitiesContainerView)
    }
    
    private func activateConstraints() {
        activateConstraintsActivitiesCountLabel()
        activateConstraintsActivitiesContainerView()
    }
    
    private func activateConstraintsActivitiesCountLabel() {
        activitiesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let labelToTop = activitiesCountLabel.topAnchor.constraint(
            equalTo: layoutMarginsGuide.topAnchor
        )
        let labelToTrailing = activitiesCountLabel.trailingAnchor.constraint(
            equalTo: layoutMarginsGuide.trailingAnchor
        )
        
        labelToTop.identifier = ConstraintIdentifiers.activitiesCountLabelToTop
        labelToTrailing.identifier = ConstraintIdentifiers.activitiesCountLabelToTrailing
        
        NSLayoutConstraint.activate([labelToTop, labelToTrailing])
    }
    
    private func activateConstraintsActivitiesContainerView() {
        activitiesContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerToTop = activitiesContainerView.topAnchor.constraint(
            equalTo: activitiesCountLabel.bottomAnchor,
            constant: Metrics.standardSpacing
        )
        let containerToLeading = activitiesContainerView.leadingAnchor.constraint(
            equalTo: leadingAnchor
        )
        let containerToTrailing = activitiesContainerView.trailingAnchor.constraint(
            equalTo: trailingAnchor
        )
        let containerToBottom = activitiesContainerView.bottomAnchor.constraint(
            equalTo: bottomAnchor
        )
        
        containerToTop.identifier = ConstraintIdentifiers.activitiesContainerViewToTop
        containerToLeading.identifier = ConstraintIdentifiers.activitiesContainerViewToLeading
        containerToTrailing.identifier = ConstraintIdentifiers.activitiesContainerViewToTrailing
        containerToBottom.identifier = ConstraintIdentifiers.activitiesContainerViewToBottom
        
        NSLayoutConstraint.activate(
            [containerToTop, containerToLeading, containerToTrailing, containerToBottom]
        )
    }
}

// MARK: - Constants
extension LandingRootView {
    
    struct AccessibilityIdentifiers {
        static let rootView                  = "rootView"
        static let activitiesCountLabel      = "activitiesCountLabel"
        static let activitiesContainerView   = "activitiesContainerView"
    }
    
    struct ConstraintIdentifiers {
        static let activitiesCountLabelToTop           = "labelToTop"
        static let activitiesCountLabelToTrailing      = "labelToTrailing"
        static let activitiesContainerViewToTop        = "containerToTop"
        static let activitiesContainerViewToLeading    = "containerToLeading"
        static let activitiesContainerViewToTrailing   = "containerToTrailing"
        static let activitiesContainerViewToBottom     = "containerToBottom"
    }
    
    struct Metrics {
        static let standardSpacing   = CGFloat(8.0)
        static let largeSpacing      = CGFloat(16.0)
    }
}
