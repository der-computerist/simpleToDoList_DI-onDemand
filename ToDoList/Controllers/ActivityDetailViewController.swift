//
//  ActivityDetailViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

private typealias ActivityDetails = (name: String, description: String, status: ActivityStatus)

private struct Constants {
    static let activityNameMaxCharacters = 50
    static let activityDescriptionMaxCharacters = 200
}

public protocol ActivityDetailViewControllerDelegate: AnyObject {
    
    func activityDetailViewControllerDidCancel(
        _ activityDetailViewController: ActivityDetailViewController
    )
    func activityDetailViewControllerDidFinish(
        _ activityDetailViewController: ActivityDetailViewController
    )
}

public final class ActivityDetailViewController: NiblessViewController {
    
    // MARK: - Properties
    public weak var delegate: ActivityDetailViewControllerDelegate?
    
    private let flow: ActivityDetailView
    private var activity: Activity
    private var isFirstLayout = true
    
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
    
    private var rootView: ActivityDetailRootView! {
        guard isViewLoaded else { return nil }
        return (view as! ActivityDetailRootView)
    }
    
    private lazy var cancelButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel(_:))
        )
        return buttonItem
    }()
    
    private lazy var saveButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(save(_:))
        )
        return buttonItem
    }()

    // MARK: - Methods
    public init(for flow: ActivityDetailView) {
        self.flow = flow
        activity = flow.activity
        originalActivityDetails = (activity.name, activity.description ?? "", activity.status)
        editedActivityDetails = originalActivityDetails
        super.init()
        
        switch flow {
        case .newActivity:
            navigationItem.title = "New Activity"
            navigationItem.rightBarButtonItem = saveButtonItem
            
        case .existingActivity:
            navigationItem.title = "Details"
            navigationItem.rightBarButtonItem = editButtonItem
        }
        navigationItem.leftBarButtonItem = cancelButtonItem
    }
    
    // MARK: View lifecycle
    public override func loadView() {
        view = ActivityDetailRootView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        rootView.nameField.delegate = self
        rootView.descriptionTextView.delegate = self
        setUpController(for: flow)
        wireController()
        updateViewFromActivity()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // "New activity" flow: If there are unsaved changes to the activity name,
        // enable the Save button.
        saveButtonItem.isEnabled = hasChangesInActivityName
        
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
    
    public override func viewDidLayoutSubviews() {
        if isFirstLayout {
            defer { isFirstLayout = false }
            
            // For user convenience, when creating a new activity, present the keyboard as
            // soon as the view begins to appear.
            if case .newActivity = flow {
                rootView.nameField.becomeFirstResponder()
            }
        }
    }
    
    // MARK: Actions
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
            save(editButtonItem)
        }
    }
    
    // MARK: Private
    private func setUpController(for flow: ActivityDetailView) {
        switch flow {
        case .newActivity:
            rootView.statusStackView.isHidden = true
        case .existingActivity:
            rootView.nameField.isEnabled = false
            rootView.descriptionTextView.isUserInteractionEnabled = false
        }
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
        GlobalToDoListActivityRepository.save(activity: activity) { _ in
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
