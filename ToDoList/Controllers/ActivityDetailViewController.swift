//
//  ActivityDetailViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

public protocol ActivityDetailViewControllerDelegate: AnyObject {
    
    func activityDetailViewControllerDidCancel(_ viewController: ActivityDetailViewController)
    func activityDetailViewControllerDidFinish(_ viewController: ActivityDetailViewController)
}

public final class ActivityDetailViewController: NiblessViewController {
    
    private struct Constants {
        static let activityNameMaxCharacters = 50
        static let activityDescriptionMaxCharacters = 200
    }
    
    private typealias ActivityDetails =
        (name: String, description: String, status: Activity.ActivityStatus)

    // MARK: - Properties
    public weak var delegate: ActivityDetailViewControllerDelegate?
    
    private let flow: ActivityDetailView
    private var activity: Activity

    private let originalActivityDetails: ActivityDetails
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
    private var isFirstLayout = true

    private var rootView: ActivityDetailRootView! {
        guard isViewLoaded else { return nil }
        return (view as! ActivityDetailRootView)
    }
    
    private lazy var cancelButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(handleCancelPressed(sender:))
        )
        return buttonItem
    }()
    
    private lazy var saveButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(handleSavePressed(sender:))
        )
        return buttonItem
    }()

    // MARK: - Methods
    public init(for flow: ActivityDetailView) {
        self.flow = flow
        activity = self.flow.activity
        originalActivityDetails = (activity.name, activity.description ?? "", activity.status)
        editedActivityDetails = originalActivityDetails
        super.init()
        
        navigationItem.title = self.flow.title
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem =
            self.flow.isNewActivity ? saveButtonItem : editButtonItem
    }
    
    // MARK: View lifecycle
    public override func loadView() {
        view = ActivityDetailRootView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        rootView.nameField.delegate = self
        rootView.descriptionTextView.delegate = self
        setUpController()
        wireController()
        updateViewFromActivity()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if flow.isNewActivity {
            // If there are unsaved changes to the activity name, enable the Save button.
            saveButtonItem.isEnabled = hasChangesInActivityName
        }
        
        if flow.isExistingActivity {
            /*
             - While out of editing mode, the "Edit/Done" button item always remains enabled.
             - After entering editing mode, the "Edit/Done" button will remain disabled as long
               as there are no edits. As soon as edits are made, it will become enabled. It will
               disable itself again if the activity name becomes empty.
             */
            editButtonItem.isEnabled =
                !isEditing || (hasChanges != editedActivityDetails.name.isEmpty)
        }

        // If there are unsaved changes overall, disable the ability to dismiss
        // using the pull-down gesture.
        isModalInPresentation = hasChanges
    }
    
    public override func viewDidLayoutSubviews() {
        if isFirstLayout {
            defer { isFirstLayout = false }
            
            // For user convenience, when creating a new activity, present the keyboard as
            // soon as the view begins to appear.
            if flow.isNewActivity {
                rootView.nameField.becomeFirstResponder()
            }
        }
    }
    
    // MARK: Actions
    @objc
    func handleSavePressed(sender: UIBarButtonItem) {
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
    func handleCancelPressed(sender: UIBarButtonItem) {
        if hasChanges {
            // The user tapped Cancel with unsaved changes. Confirm that it's OK to lose the changes.
            confirmCancel()
        } else {
            // There are no unsaved changes; ask the delegate to dismiss immediately.
            delegate?.activityDetailViewControllerDidCancel(self)
        }
    }
    
    @objc
    func toggleStatus(_ sender: UISwitch) {
        editedActivityDetails.status = sender.isOn ? .done : .pending
    }
    
    // MARK: Editing Mode
    public override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            rootView.nameField.isEnabled = true
            rootView.descriptionTextView.isUserInteractionEnabled = true
            rootView.doneSwitch.isEnabled = true
            editButtonItem.isEnabled = false
            rootView.nameField.becomeFirstResponder()
            
        } else {
            isEditing = true  // do not exit editing mode until the save is successful
            handleSavePressed(sender: editButtonItem)
        }
    }
    
    // MARK: Private
    private func setUpController() {
        rootView.statusStackView.isHidden = flow.hidesActivityStatus
        rootView.nameField.isEnabled = flow.enablesNameField
        rootView.descriptionTextView.isUserInteractionEnabled = flow.enablesDescriptionField
    }
    
    private func wireController() {
        rootView.doneSwitch.addTarget(self, action: #selector(toggleStatus(_:)), for: .valueChanged)
    }
    
    private func updateViewFromActivity() {
        rootView.nameField.text = activity.name
        rootView.descriptionTextView.text = activity.description
        rootView.doneSwitch.isOn = activity.status == .done ? true : false
    }
    
    private func validateInputs() throws {
        guard let activityName = rootView.nameField.text else {
            throw ActivityCreationError.nameEmpty
        }
        
        let activityDescription = rootView.descriptionTextView.text ?? ""
        
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
        updateActivityFromView()
        GlobalToDoListActivityRepository.update(activity: activity) { _ in
            self.delegate?.activityDetailViewControllerDidFinish(self)
        }
    }
    
    private func updateActivityFromView() {
        activity.name = editedActivityDetails.name
        activity.description = editedActivityDetails.description
        activity.status = editedActivityDetails.status
    }
}

// MARK: - UITextFieldDelegate

extension ActivityDetailViewController: UITextFieldDelegate {
    
    public func textField(
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
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension ActivityDetailViewController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        editedActivityDetails.description = textView.text
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension ActivityDetailViewController: UIAdaptivePresentationControllerDelegate {
    
    public func presentationControllerDidAttemptToDismiss(_ _: UIPresentationController) {
        // A user-initiated attempt to dismiss the view was prevented because
        // there were unsaved changes. Ask the user to confirm their intention.
        confirmCancel()
    }
}