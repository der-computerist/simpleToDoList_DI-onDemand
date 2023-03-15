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
        stackView.spacing = Metrics.standardSpacing
        stackView.accessibilityIdentifier = AccessibilityIdentifiers.formStackView
        return stackView
    }()
    
    lazy var nameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, nameField])
        stackView.axis = .horizontal
        stackView.spacing = Metrics.largeSpacing
        stackView.accessibilityIdentifier = AccessibilityIdentifiers.nameStackView
        return stackView
    }()
    
    lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextView])
        stackView.axis = .horizontal
        stackView.spacing = Metrics.largeSpacing
        stackView.alignment = .top
        stackView.accessibilityIdentifier = AccessibilityIdentifiers.descriptionStackView
        return stackView
    }()
    
    lazy var statusStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [doneLabel, doneSwitch])
        stackView.axis = .horizontal
        stackView.spacing = Metrics.largeSpacing
        stackView.accessibilityIdentifier = AccessibilityIdentifiers.statusStackView
        return stackView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.nameLabelText
        label.accessibilityIdentifier = AccessibilityIdentifiers.nameLabel
        return label
    }()
    
    let nameField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultHigh - 10, for: .horizontal)
        field.accessibilityIdentifier = AccessibilityIdentifiers.nameField
        return field
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.descriptionLabelText
        label.accessibilityIdentifier = AccessibilityIdentifiers.descriptionLabel
        return label
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = Metrics.descriptionTextViewBorderWidth
        textView.layer.cornerRadius = Metrics.descriptionTextViewCornerRadius
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
        textView.accessibilityIdentifier = AccessibilityIdentifiers.descriptionTextView
        return textView
    }()
    
    let doneLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.doneLabelText
        label.accessibilityIdentifier = AccessibilityIdentifiers.doneLabel
        return label
    }()
    
    let doneSwitch: UISwitch = {
        let `switch` = UISwitch()
        `switch`.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        `switch`.isEnabled = false
        `switch`.accessibilityIdentifier = AccessibilityIdentifiers.doneSwitch
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
        accessibilityIdentifier = AccessibilityIdentifiers.rootView
        
        // Layout margins
        var customMargins = layoutMargins
        customMargins.top = Metrics.largeSpacing
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
            multiplier: Metrics.formStackViewHeightMultiplier
        )
        
        formToLeading.identifier = ConstraintIdentifiers.formStackViewToLeading
        formToTrailing.identifier = ConstraintIdentifiers.formStackViewToTrailing
        formToTop.identifier = ConstraintIdentifiers.formStackViewToTop
        formHeight.identifier = ConstraintIdentifiers.formStackViewHeight

        NSLayoutConstraint.activate([formToLeading, formToTrailing, formToTop, formHeight])
    }
    
    private func activateConstraintsNameField() {
        nameField.translatesAutoresizingMaskIntoConstraints = false
        
        let nameFieldLeadingAlignment = nameField.leadingAnchor.constraint(
            equalTo: descriptionTextView.leadingAnchor
        )
        
        nameFieldLeadingAlignment.identifier = ConstraintIdentifiers.nameFieldLeadingAlignment
        nameFieldLeadingAlignment.isActive = true
    }
    
    private func activateConstraintsDescriptionTextView() {
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionTextViewHeight = descriptionTextView.heightAnchor.constraint(
            equalTo: descriptionStackView.heightAnchor
        )
        
        descriptionTextViewHeight.identifier = ConstraintIdentifiers.descriptionTextViewHeight
        descriptionTextViewHeight.isActive = true
    }
    
    private func activateConstraintsDoneSwitch() {
        doneSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let doneSwitchLeadingAlignment = doneSwitch.leadingAnchor.constraint(
            equalTo: descriptionTextView.leadingAnchor
        )
        
        doneSwitchLeadingAlignment.identifier = ConstraintIdentifiers.doneSwitchLeadingAlignment
        doneSwitchLeadingAlignment.isActive = true
    }
}

// MARK: - Constants
extension ActivityDetailRootView {
    
    struct AccessibilityIdentifiers {
        static let rootView               = "rootView"
        static let formStackView          = "formStackView"
        static let nameStackView          = "nameStackView"
        static let descriptionStackView   = "descriptionStackView"
        static let statusStackView        = "statusStackView"
        static let nameLabel              = "nameLabel"
        static let nameField              = "nameField"
        static let descriptionLabel       = "descriptionLabel"
        static let descriptionTextView    = "descriptionTextView"
        static let doneLabel              = "doneLabel"
        static let doneSwitch             = "doneSwitch"
    }
    
    struct Constants {
        static let nameLabelText          = "Name"
        static let descriptionLabelText   = "Description"
        static let doneLabelText          = "Done"
    }
    
    struct ConstraintIdentifiers {
        static let formStackViewToLeading       = "formToLeading"
        static let formStackViewToTrailing      = "formToTrailing"
        static let formStackViewToTop           = "formToTop"
        static let formStackViewHeight          = "formHeight"
        static let nameFieldLeadingAlignment    = "nameFieldLeadingAlignment"
        static let descriptionTextViewHeight    = "descriptionTextViewHeight"
        static let doneSwitchLeadingAlignment   = "doneSwitchLeadingAlignment"
    }
    
    struct Metrics {
        static let standardSpacing                   = CGFloat(8.0)
        static let largeSpacing                      = CGFloat(16.0)
        static let descriptionTextViewBorderWidth    = CGFloat(1.0)
        static let descriptionTextViewCornerRadius   = CGFloat(5.0)
        static let formStackViewHeightMultiplier     = CGFloat(1.0/3)
    }
}
