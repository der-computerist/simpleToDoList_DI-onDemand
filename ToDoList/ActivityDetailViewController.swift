//
//  ActivityDetailViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

private typealias ActivityDetails = (name: String, description: String)

private struct Constants {
    static let activityNameMaxCharacters = 50
    static let activityDescriptionMaxCharacters = 200
}

protocol ActivityDetailViewControllerDelegate: AnyObject {
    
    func activityDetailViewControllerDidCancel(
        _ activityDetailViewController: ActivityDetailViewController
    )
    func activityDetailViewControllerDidFinish(
        _ activityDetailViewController: ActivityDetailViewController
    )
}

final class ActivityDetailViewController: NiblessViewController {
    
    // MARK: - Properties
    public var onDismiss: (() -> Void)?
    let flow: ActivityDetailView
    var activity: Activity
    weak var delegate: ActivityDetailViewControllerDelegate?
    
    private var originalActivityDetails: ActivityDetails
    private var editedActivityDetails: ActivityDetails {
        didSet {
            viewIfLoaded?.setNeedsLayout()
        }
    }
    
    private var hasChanges: Bool {
        originalActivityDetails != editedActivityDetails
    }
    private var hasChangesInActivityName: Bool {
        originalActivityDetails.name != editedActivityDetails.name
    }
    
    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel(_:))
        )
        return button
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(save(_:))
        )
        return button
    }()

    private lazy var rootView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        view.accessibilityIdentifier = "rootView"
        
        // Layout margins
        var customMargins = view.layoutMargins
        customMargins.top = 16
        view.layoutMargins = customMargins
        
        return view
    }()
    
    private lazy var formStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [nameStackView, descriptionStackView, statusStackView]
        )
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.accessibilityIdentifier = "formStackView"
        return stackView
    }()
    
    private lazy var nameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, nameField])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.accessibilityIdentifier = "nameStackView"
        return stackView
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextView])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .top
        stackView.accessibilityIdentifier = "descriptionStackView"
        return stackView
    }()
    
    private lazy var statusStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [doneLabel, doneSwitch])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.accessibilityIdentifier = "statusStackView"
        return stackView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.accessibilityIdentifier = "nameLabel"
        return label
    }()
    
    private lazy var nameField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultHigh - 10, for: .horizontal)
        if case .existingActivity = flow {
            field.isEnabled = false
        }
        field.accessibilityIdentifier = "nameField"
        field.delegate = self
        return field
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.accessibilityIdentifier = "descriptionLabel"
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
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
        if case .existingActivity = flow {
            textView.isUserInteractionEnabled = false
        }
        textView.accessibilityIdentifier = "descriptionTextView"
        textView.delegate = self
        return textView
    }()
    
    private lazy var doneLabel: UILabel = {
        let label = UILabel()
        label.text = "Done"
        label.accessibilityIdentifier = "doneLabel"
        return label
    }()
    
    private lazy var doneSwitch: UISwitch = {
        let `switch` = UISwitch()
        `switch`.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        `switch`.accessibilityIdentifier = "doneSwitch"
        return `switch`
    }()
    
    // MARK: - Methods
    public init(for flow: ActivityDetailView) {
        self.flow = flow
        activity = flow.activity
        originalActivityDetails = (activity.name, activity.description ?? "")
        editedActivityDetails = originalActivityDetails
        super.init()
        
        switch flow {
        case .newActivity:
            navigationItem.title = "New Activity"
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = saveButton
            
        case .existingActivity:
            navigationItem.title = "Details"
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem = editButtonItem
        }
    }
    
    // MARK: View lifecycle
    override func loadView() {
        view = rootView
        constructViewHierarchy()
        activateConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = activity.name
        descriptionTextView.text = activity.description
        
        // For user convenience, when creating a new activity, present the keyboard as
        // soon as the view begins appearing.
        if case .newActivity = flow {
            nameField.becomeFirstResponder()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // "New activity" flow: If there are unsaved changes to the activity name,
        // enable the Save button.
        saveButton.isEnabled = hasChangesInActivityName
        
        /*
          "Existing activity" flow:
              * While out of editing mode, the "Edit/Done" button item always remains enabled.
              * After entering editing mode, the "Edit/Done" button will remain disabled as long
                as there are no edits. As soon as edits are made, it will become enabled. It will
                disable itself again if the activity name becomes empty.
         */
        editButtonItem.isEnabled = !isEditing || (hasChanges != editedActivityDetails.name.isEmpty)

        // Both flows: If there are unsaved changes overall, disable the ability to dismiss
        // using the pull-down gesture.
        isModalInPresentation = hasChanges
    }
    
    // MARK: Button actions
    @objc
    func save(_ sender: UIBarButtonItem) {
        do {
            try validateInputs()
            confirmSave()
        } catch {
            presentErrorAlert(
                title: ActivityCreationError.title,
                message: error.localizedDescription
            )
        }
    }
    
    @objc
    func cancel(_ sender: UIBarButtonItem) {
        if hasChanges {
            // The user tapped Cancel with unsaved changes. Confirm that it's OK to lose the changes.
            confirmCancel()
        } else {
            // There are no unsaved changes; ask the delegate to dismiss immediately.
            delegate?.activityDetailViewControllerDidCancel(self)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            nameField.isEnabled = true
            descriptionTextView.isUserInteractionEnabled = true
            editButtonItem.isEnabled = false
            nameField.becomeFirstResponder()
            
        } else {
            isEditing = true  // do not exit editing mode until the save is successful
            save(editButtonItem)
        }
    }
    
    // MARK: Private
    private func constructViewHierarchy() {
        if case .newActivity = flow {
            statusStackView.isHidden = true
        }
        view.addSubview(formStackView)
    }
    
    private func activateConstraints() {
        activateConstraintsFormStackView()
        activateConstraintsNameField()
        activateConstraintsDescriptionTextView()
        activateConstraintsDoneSwitch()
    }
    
    private func activateConstraintsFormStackView() {
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.layoutMarginsGuide
        let formToLeading = formStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        let formToTrailing = formStackView.trailingAnchor.constraint(
            equalTo: margins.trailingAnchor
        )
        let formToTop = formStackView.topAnchor.constraint(equalTo: margins.topAnchor)
        let formHeight = formStackView.heightAnchor.constraint(
            equalTo: view.heightAnchor,
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
    
    private func validateInputs() throws {
        guard let activityName = nameField.text else {
            throw ActivityCreationError.nameEmpty
        }
        
        let activityDescription = descriptionTextView.text ?? ""
        
        if activityName.count > Constants.activityNameMaxCharacters {
            throw ActivityCreationError.nameTooLong(
                maxCharacters: Constants.activityNameMaxCharacters
            )

        } else if activityDescription.count > Constants.activityDescriptionMaxCharacters {
            throw ActivityCreationError.descriptionTooLong(
                maxCharacters: Constants.activityDescriptionMaxCharacters
            )
        }
    }
    
    private func confirmSave() {
        let alert = UIAlertController(
            title: "Confirmation",
            message: "Are you sure?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.saveAndDismiss()
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func confirmCancel() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
            self.delegate?.activityDetailViewControllerDidCancel(self)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.pruneNegativeWidthConstraints()  // workaround to circumvent a UIKit bug
        present(alert, animated: true, completion: nil)
    }
    
    private func saveAndDismiss() {
        activity.name = nameField.text ?? ""
        activity.description = descriptionTextView.text
        presentingViewController?.dismiss(animated: true, completion: onDismiss)
    }
}

// MARK: - UITextFieldDelegate

extension ActivityDetailViewController: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let oldText = textField.text else {
            return false
        }
        
        let newText = oldText.replacingCharacters(in: Range(range, in: oldText)!, with: string)
        editedActivityDetails.name = newText
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension ActivityDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        editedActivityDetails.description = textView.text
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension ActivityDetailViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(
        _ presentationController: UIPresentationController
    ) {
        // A user-initiated attempt to dismiss the view was prevented because
        // there were unsaved changes. Ask the user to confirm their intention.
        confirmCancel()
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // A user-initiated attempt to dismiss the view was allowed because
        // there were no unsaved changes. Do not preserve the created activity.
        // (It's OK to dismiss programmatically here. No side effects.)
        delegate?.activityDetailViewControllerDidCancel(self)
    }
}
