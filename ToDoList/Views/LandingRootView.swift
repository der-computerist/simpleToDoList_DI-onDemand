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
    
    public let activitiesCountLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "activitiesCountLabel"
        return label
    }()
    
    public let activitiesContainerView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "activitiesContainerView"
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
        accessibilityIdentifier = "rootView"
        
        // Layout margins
        var customMargins = layoutMargins
        customMargins.top = 16
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
        
        labelToTop.identifier = "labelToTop"
        labelToTrailing.identifier = "labelToTrailing"
        
        NSLayoutConstraint.activate([labelToTop, labelToTrailing])
    }
    
    private func activateConstraintsActivitiesContainerView() {
        activitiesContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerToTop = activitiesContainerView.topAnchor.constraint(
            equalTo: activitiesCountLabel.bottomAnchor,
            constant: 8
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
        
        containerToTop.identifier = "containerToTop"
        containerToLeading.identifier = "containerToLeading"
        containerToTrailing.identifier = "containerToTrailing"
        containerToBottom.identifier = "containerToBottom"
        
        NSLayoutConstraint.activate(
            [containerToTop, containerToLeading, containerToTrailing, containerToBottom]
        )
    }
}
