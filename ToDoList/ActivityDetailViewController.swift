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

final class ActivityDetailViewController: NiblessViewController {
    
    // MARK: - Properties
    public var onDismiss: (() -> Void)?
    private let flow: ActivityDetailView
    private var activity: Activity
    
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
        let stackView = UIStackView(arrangedSubviews: [nameStackView, descriptionStackView])
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

        // If there are unsaved changes to the activity name, enable the Save button.
        saveButton.isEnabled = hasChangesInActivityName
        
        // If there are unsaved changes overall, disable the ability to dismiss using
        // the pull-down gesture.
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
            confirmCancel()
        } else {
            dismissWithoutSaving()
        }
    }
    
    // MARK: Private
    private func constructViewHierarchy() {
        view.addSubview(formStackView)
    }
    
    private func activateConstraints() {
        activateConstraintsFormStackView()
        activateConstraintsDescriptionTextView()
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
    
    private func activateConstraintsDescriptionTextView() {
        /*
         (Describe what you want the view to look like independent of screen size.)
         
         I want the `descriptionTextView` to be:
             * 16 points from the right edge of the `descriptionLabel`
             * 16 point from the right edge of the screen
             * aligned with the `descriptionLabel` on its first baseline
             * as tall as 1/3 of the screen height
         —————————————————————————————————————————————
         (Turn the description into constraints.)
         
         Constraints for the `descriptionTextView`:
             * The text view's left edge should be 16 points away from its nearest neighbor.
             * The text view's right edge should be 16 points away from its superview.
             * The text view's first baseline should be aligned with the first baseline of
                its nearest left neighbor.
             * The text view's height should be equal to 1/3 of the height of its superview.
         —————————————————————————————————————————————
        (Express constraints in terms of anchors.)
         
         Constraints for the `descriptionTextView`:
             * The first baseline anchor of the text view should be aligned with the first
                baseline anchor of the `descriptionLabel`.
             * The leading anchor of the text view should be 16 points away from the trailing
                anchor of the `descriptionLabel`.
             * The trailing anchor of the text view should be 16 points away from the
                trailing anchor of its superview.
             * The height attribute of the text view should be equal to 1/3 of the height
                of its superview.
         */
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionTextViewLeadingAlignment = descriptionTextView.leadingAnchor.constraint(
            equalTo: nameField.leadingAnchor
        )
        let descriptionTextViewHeight = descriptionTextView.heightAnchor.constraint(
            equalTo: descriptionStackView.heightAnchor
        )
        
        descriptionTextViewLeadingAlignment.identifier = "descriptionTextViewLeadingAlignment"
        descriptionTextViewHeight.identifier = "descriptionTextViewHeight"
        
        NSLayoutConstraint.activate(
            [descriptionTextViewLeadingAlignment, descriptionTextViewHeight]
        )
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
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.saveAndDismiss()
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func confirmCancel() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(
            UIAlertAction(title: "Discard Changes", style: .destructive) { [weak self] _ in
                self?.dismissWithoutSaving()
            }
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.pruneNegativeWidthConstraints()  // workaround to circumvent a UIKit bug
        present(alert, animated: true, completion: nil)
    }
    
    private func saveAndDismiss() {
        activity.name = nameField.text ?? ""
        activity.description = descriptionTextView.text
        presentingViewController?.dismiss(animated: true, completion: onDismiss)
    }
    
    private func dismissWithoutSaving() {
        if case .newActivity = flow {
            GlobalToDoListActivityRepository.delete(activity: activity, completion: nil)
        }
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
        dismissWithoutSaving()
    }
}
