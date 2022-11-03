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
    
    // MARK: - Type properties
    static let viewControllerIdentifier = String(describing: ActivityDetailViewController.self)

    // MARK: - Instance properties
    public weak var delegate: ActivityDetailViewControllerDelegate?
    
    private let flow: ActivityDetailView
    private var activity: Activity
    private lazy var activityBuilder = ActivityBuilder(activity: activity) {
        didSet {
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
    
    // MARK: State Restoration
    /**
     If state restoration occurred, this flag indicates whether the view controller was
     in editing mode or not when the app was suspended.
     */
    private var wasEditing = false
    
    /**
     If state restoration occurred, this variable holds a reference to which field was
     active (first responder) when the app was suspended.
     */
    private var lastActiveField: UIView?

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
        
        restorationIdentifier = Self.viewControllerIdentifier
        restorationClass = type(of: self)
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
            
            switch flow {
            case .newActivity:
                // When creating a new activity, present the keyboard as soon as the view
                // begins to appear.
                showKeyboard()
            case .existingActivity:
                // If state restoration occurred, restore the editing state of the
                // view controller.
                if wasEditing { isEditing = wasEditing }
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
        // Handle tap on "Done"
        if !editing {
            handleSavePressed(sender: editButtonItem)
            return
        }
        
        // Handle tap on "Edit"
        super.setEditing(editing, animated: animated)
        updateViewForEditing(editing)
        rootView.setNeedsLayout()
        showKeyboard()
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
        rootView.nameField.text = activityBuilder.name
        rootView.descriptionTextView.text = activityBuilder.description
        rootView.doneSwitch.isOn = activityBuilder.status == .done ? true : false
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
    
    private func updateViewForEditing(_ editing: Bool) {
        rootView.nameField.isEnabled = editing
        rootView.descriptionTextView.isUserInteractionEnabled = editing
        rootView.doneSwitch.isEnabled = editing
    }
    
    private func showKeyboard() {
        (lastActiveField ?? rootView.nameField).becomeFirstResponder()
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
    
    public func presentationControllerDidDismiss(_ _: UIPresentationController) {
        delegate?.activityDetailViewControllerDidCancel(self)
    }
}

// MARK: - State Restoration
extension ActivityDetailViewController {

    static let activityIDKey = "activityID"
    static let activityDetailViewControllerIsEditingKey = "activityDetailViewControllerIsEditing"
    static let activityHasUnsavedChangesKey = "activityHasUnsavedChanges"
    static let editedNameKey = "editedName"
    static let editedDescriptionKey = "editedDescription"
    static let editedStatusKey = "editedStatus"
    static let activeFieldKey = "activeField"

    public override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        // Preserve the activity ID and editing state only if we are editing an existing activity.
        if case .existingActivity = flow {
            coder.encode(activity.id, forKey: Self.activityIDKey)
            coder.encode(isEditing, forKey: Self.activityDetailViewControllerIsEditingKey)
        }
        
        // Write out any temporary data if editing is in progress.
        if activityBuilder.hasChanges() {
            coder.encode(activityBuilder.hasChanges(), forKey: Self.activityHasUnsavedChangesKey)
            coder.encode(activityBuilder.name, forKey: Self.editedNameKey)
            coder.encode(activityBuilder.description, forKey: Self.editedDescriptionKey)
            coder.encode(activityBuilder.status.rawValue, forKey: Self.editedStatusKey)
        }
        
        // Keep track of the active field.
        if rootView.nameField.isFirstResponder {
            coder.encode(Int32(1), forKey: Self.activeFieldKey)
            
        } else if rootView.descriptionTextView.isFirstResponder {
            coder.encode(Int32(2), forKey: Self.activeFieldKey)
            
        } else {
            coder.encode(Int32(0), forKey: Self.activeFieldKey)  // No field was active
        }
    }

    public override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        // Decode the editing state only if we were editing an existing activity.
        if case .existingActivity = flow {
            wasEditing = coder.decodeBool(forKey: Self.activityDetailViewControllerIsEditingKey)
        }
        
        // Restore any unsaved data if editing was in progress.
        let activityHasUnsavedChanges = coder.decodeBool(forKey: Self.activityHasUnsavedChangesKey)
        if activityHasUnsavedChanges {
            if let name = coder.decodeObject(forKey: Self.editedNameKey) as? String {
                activityBuilder.name = name
            }
            if let description = coder.decodeObject(forKey: Self.editedDescriptionKey) as? String {
                activityBuilder.description = description
            }
            let rawStatus = coder.decodeInteger(forKey: Self.editedStatusKey)
            if let status = Activity.Status(rawValue: rawStatus) {
                activityBuilder.status = status
            }
        }

        // Decode the identity of the last active field (if any).
        let activeField = coder.decodeInteger(forKey: Self.activeFieldKey)
        switch activeField {
        case 1:
            lastActiveField = rootView.nameField
        case 2:
            lastActiveField = rootView.descriptionTextView
        default:
            lastActiveField = nil
        }
    }

    public override func applicationFinishedRestoringState() {
        updateViewFromActivity()
    }
}

extension ActivityDetailViewController: UIViewControllerRestoration {

    public static func viewController(
        withRestorationIdentifierPath identifierComponents: [String],
        coder: NSCoder
    ) -> UIViewController? {

        if let activityID = coder.decodeObject(forKey: Self.activityIDKey) as? String,
           let activity = GlobalToDoListActivityRepository.activity(fromIdentifier: activityID) {
            return self.init(for: .existingActivity(activity))
        } else {
            return self.init(for: .newActivity)
        }
    }
}
