//
//  ActivityDetailRootView.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 4/28/22.
//

import UIKit

public final class ActivityDetailRootView: NiblessView {
    
    // MARK: - Properties
    private var hierarchyNotReady = true
    
    lazy var formStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [nameStackView, descriptionStackView, statusStackView]
        )
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.accessibilityIdentifier = "formStackView"
        return stackView
    }()
    
    lazy var nameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, nameField])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.accessibilityIdentifier = "nameStackView"
        return stackView
    }()
    
    lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextView])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .top
        stackView.accessibilityIdentifier = "descriptionStackView"
        return stackView
    }()
    
    lazy var statusStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [doneLabel, doneSwitch])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.accessibilityIdentifier = "statusStackView"
        return stackView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.accessibilityIdentifier = "nameLabel"
        return label
    }()
    
    let nameField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultHigh - 10, for: .horizontal)
        field.accessibilityIdentifier = "nameField"
        return field
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.accessibilityIdentifier = "descriptionLabel"
        return label
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.black
            default:
                return UIColor.white
            }
        }
        textView.layer.borderColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemGray4
            default:
                return UIColor.systemGray3
            }
        }.cgColor
        textView.accessibilityIdentifier = "descriptionTextView"
        return textView
    }()
    
    let doneLabel: UILabel = {
        let label = UILabel()
        label.text = "Done"
        label.accessibilityIdentifier = "doneLabel"
        return label
    }()
    
    let doneSwitch: UISwitch = {
        let `switch` = UISwitch()
        `switch`.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        `switch`.isEnabled = false
        `switch`.accessibilityIdentifier = "doneSwitch"
        return `switch`
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
        addSubview(formStackView)
    }
    
    private func activateConstraints() {
        activateConstraintsFormStackView()
        activateConstraintsNameField()
        activateConstraintsDescriptionTextView()
        activateConstraintsDoneSwitch()
    }
    
    private func activateConstraintsFormStackView() {
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let formToLeading = formStackView.leadingAnchor.constraint(
            equalTo: layoutMarginsGuide.leadingAnchor
        )
        let formToTrailing = formStackView.trailingAnchor.constraint(
            equalTo: layoutMarginsGuide.trailingAnchor
        )
        let formToTop = formStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        let formHeight = formStackView.heightAnchor.constraint(
            equalTo: heightAnchor,
            multiplier: 1.0/3
        )
        
        formToLeading.identifier = "formToLeading"
        formToTrailing.identifier = "formToTrailing"
        formToTop.identifier = "formToTop"
        formHeight.identifier = "formHeight"

        NSLayoutConstraint.activate([formToLeading, formToTrailing, formToTop, formHeight])
    }
    
    private func activateConstraintsNameField() {
        nameField.translatesAutoresizingMaskIntoConstraints = false
        
        let nameFieldLeadingAlignment = nameField.leadingAnchor.constraint(
            equalTo: descriptionTextView.leadingAnchor
        )
        
        nameFieldLeadingAlignment.identifier = "nameFieldLeadingAlignment"
        nameFieldLeadingAlignment.isActive = true
    }
    
    private func activateConstraintsDescriptionTextView() {
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionTextViewHeight = descriptionTextView.heightAnchor.constraint(
            equalTo: descriptionStackView.heightAnchor
        )
        
        descriptionTextViewHeight.identifier = "descriptionTextViewHeight"
        descriptionTextViewHeight.isActive = true
    }
    
    private func activateConstraintsDoneSwitch() {
        doneSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let doneSwitchLeadingAlignment = doneSwitch.leadingAnchor.constraint(
            equalTo: descriptionTextView.leadingAnchor
        )
        
        doneSwitchLeadingAlignment.identifier = "doneSwitchLeadingAlignment"
        doneSwitchLeadingAlignment.isActive = true
    }
}
