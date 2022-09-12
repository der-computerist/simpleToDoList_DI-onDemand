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
    
    // MARK: - Properties
    public weak var delegate: ActivityDetailViewControllerDelegate?
    
    private let flow: ActivityDetailView
    private var activity: Activity
    private lazy var activityBuilder = ActivityBuilder(activity: activity) {
        didSet{
            viewIfLoaded?.setNeedsLayout()
        }
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
        
        if let existingActivity = self.flow.activity {
            activity = existingActivity
        } else {
            activity = Activity(name: "",
                                description: "",
                                status: .pending,
                                id: UUID().uuidString,
                                dateCreated: Date())
        }
        
        super.init()
        
        navigationItem.title = self.flow.title
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem =
            self.flow == .newActivity ? saveButtonItem : editButtonItem
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
        
        if case .newActivity = flow {
            // If there are unsaved changes to the activity name, enable the Save button.
            saveButtonItem.isEnabled = activityBuilder.hasNameChanges()
        }

        if case .existingActivity = flow {
            /*
             - While out of editing mode, the "Edit/Done" button item always remains enabled.
             - After entering editing mode, the "Edit/Done" button will remain disabled as long
               as there are no edits. As soon as edits are made, it will become enabled. It will
               disable itself again if the activity name becomes empty.
             */
            editButtonItem.isEnabled =
                !isEditing || (activityBuilder.hasChanges() != activityBuilder.name.isEmpty)
        }

        // If there are unsaved changes overall, disable the ability to dismiss
        // using the pull-down gesture.
        isModalInPresentation = activityBuilder.hasChanges()
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
    func handleSavePressed(sender: UIBarButtonItem) {
        do {
            activity = try activityBuilder.build()
            confirmSave()
        } catch {
            presentErrorAlert(
                title: ActivityBuilder.Error.title,
                message: error.localizedDescription
            )
        }
    }
    
    @objc
    func handleCancelPressed(sender: UIBarButtonItem) {
        if activityBuilder.hasChanges() {
            // The user tapped Cancel while having unsaved changes.
            // Confirm that it's OK to lose the changes.
            confirmCancel()
        } else {
            // There are no unsaved changes; ask the delegate to dismiss immediately.
            delegate?.activityDetailViewControllerDidCancel(self)
        }
    }
    
    @objc
    func toggleStatus(_ sender: UISwitch) {
        activityBuilder.status = sender.isOn ? .done : .pending
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
        GlobalToDoListActivityRepository.update(activity: activity) { _ in
            self.delegate?.activityDetailViewControllerDidFinish(self)
        }
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
        activityBuilder.name = newText
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
        activityBuilder.description = textView.text
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
