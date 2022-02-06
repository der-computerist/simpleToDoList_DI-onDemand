//
//  ActivityDetailViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

private struct Constants {
    static let activityNameMaxCharacters = 50
    static let activityDescriptionMaxCharacters = 200
}

final class ActivityDetailViewController: NiblessViewController {
    
    // MARK: - Properties
    public var onDismiss: (() -> Void)?
    private let flow: ActivityDetailView
    private var activity: Activity
    
    private var originalActivityName: String
    private var editedActivityName: String {
        didSet {
            viewIfLoaded?.setNeedsLayout()
        }
    }
    private var hasChanges: Bool {
        originalActivityName != editedActivityName
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
        return stackView
    }()
    
    private lazy var nameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, nameField])
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextView])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .top
        return stackView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        return label
    }()
    
    private lazy var nameField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.delegate = self
        field.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultHigh - 10, for: .horizontal)
        return field
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    // MARK: - Methods
    public init(for flow: ActivityDetailView) {
        self.flow = flow
        activity = flow.activity
        originalActivityName = activity.name
        editedActivityName = originalActivityName
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
        styleDescriptionTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = activity.name
        descriptionTextView.text = activity.activityDescription
        
        // For user convenience, when creating a new activity, present the keyboard as
        // soon as the view begins appearing.
        if case .newActivity = flow {
            nameField.becomeFirstResponder()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // If there are unsaved changes, enable the Save button and disable the ability to
        // dismiss using the pull-down gesture.
        saveButton.isEnabled = hasChanges
        isModalInPresentation = hasChanges
    }
    
    // MARK: Button actions
    @objc
    func save(_ sender: UIBarButtonItem) {
        do {
            try validateInputs()
            confirmSave()
        } catch let error as ErrorMessage {
            present(errorMessage: error)
        } catch {
            assertionFailure("Unexpected error during input validation: \(error)")
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
    
    // MARK: Dark mode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let newUserInterfaceStyle = traitCollection.userInterfaceStyle
        let previousUserInterfaceStyle = previousTraitCollection?.userInterfaceStyle
        
        if newUserInterfaceStyle != previousUserInterfaceStyle {
            styleDescriptionTextView()
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
        let leading = formStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        let trailing = formStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        let top = formStackView.topAnchor.constraint(equalTo: margins.topAnchor)
        let height = NSLayoutConstraint(
            item: formStackView,
            attribute: .height,
            relatedBy: .equal,
            toItem: view,
            attribute: .height,
            multiplier: 1.0/3,
            constant: 0
        )
        
        NSLayoutConstraint.activate([leading, trailing, top, height])
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
        
        let leading = descriptionTextView.leadingAnchor.constraint(
            equalTo: nameField.leadingAnchor
        )
        let height = descriptionTextView.heightAnchor.constraint(
            equalTo: descriptionStackView.heightAnchor
        )
        
        NSLayoutConstraint.activate([leading, height])
    }
    
    private func styleDescriptionTextView() {
        if traitCollection.userInterfaceStyle == .dark {
            descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
            descriptionTextView.layer.backgroundColor = UIColor.black.cgColor
        } else {
            descriptionTextView.layer.borderColor = UIColor.systemGray3.cgColor
            descriptionTextView.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    private func validateInputs() throws {
        guard let activityName = nameField.text else {
            let errorMessage = ErrorMessage(
                title: "Activity Creation Error",
                message: "Activity name can't be empty."
            )
            throw errorMessage
        }
        
        let activityDescription = descriptionTextView.text ?? ""
        
        if activityName.count > Constants.activityNameMaxCharacters {
            let errorMessage = ErrorMessage(
                title: "Activity Creation Error",
                message: "Activity name exceeds max characters (50)."
            )
            throw errorMessage

        } else if activityDescription.count > Constants.activityDescriptionMaxCharacters {
            let errorMessage = ErrorMessage(
                title: "Activity Creation Error",
                message: "Activity description exceeds max characters (200)."
            )
            throw errorMessage
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
        
        present(alert, animated: true, completion: nil)
    }
    
    private func saveAndDismiss() {
        activity.name = nameField.text ?? ""
        activity.activityDescription = descriptionTextView.text
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
        editedActivityName = newText
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
