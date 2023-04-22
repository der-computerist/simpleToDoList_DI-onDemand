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

    lazy var activityBuilder = ActivityBuilder(activity: activity) {
        didSet {
            viewIfLoaded?.setNeedsLayout()
        }
    }
    
    private var activity: Activity
    private var activityDetailStrategy: ActivityDetailStrategy!
    private let activityRepository: ActivityRepository
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
    
    // MARK: State Restoration
    /**
     If state restoration occurred, this flag indicates whether the view controller was
     in editing mode or not when the app was suspended.
     */
    var wasEditing = false
    
    /**
     If state restoration occurred, this variable holds a reference to which field was
     active (first responder) when the app was suspended.
     */
    private var lastActiveField: UIView?

    // MARK: - Methods
    public init(activity: Activity?, activityRepository: ActivityRepository) {
        self.activityRepository = activityRepository
        
        if let existingActivity = activity {
            self.activity = existingActivity
        } else {
            self.activity = Activity(name: "",
                                     description: "",
                                     status: .pending,
                                     id: UUID().uuidString,
                                     dateCreated: Date())
        }
        
        super.init()
        
        if activity == nil {
            activityDetailStrategy = NewActivityStrategy(for: self)
        } else {
            activityDetailStrategy = ExistingActivityStrategy(for: self)
        }
        
        restorationIdentifier = Restoration.viewControllerIdentifier
        restorationClass = type(of: self)
        navigationItem.title = activityDetailStrategy.title
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = activityDetailStrategy.rightBarButtonItem
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
        
        activityDetailStrategy.enableOrDisableRightBarButtonItem()
        // If there are unsaved changes overall, disable the ability to dismiss
        // using the pull-down gesture.
        isModalInPresentation = activityBuilder.hasChanges()
    }
    
    public override func viewDidLayoutSubviews() {
        if isFirstLayout {
            defer { isFirstLayout = false }
            activityDetailStrategy.prepareForPresentation()
        }
    }
    
    func showKeyboard() {
        (lastActiveField ?? rootView.nameField).becomeFirstResponder()
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
        rootView.statusStackView.isHidden = activityDetailStrategy.hidesActivityStatus()
        rootView.nameField.isEnabled = activityDetailStrategy.enablesNameField()
        rootView.descriptionTextView.isUserInteractionEnabled =
            activityDetailStrategy.enablesDescriptionField()
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
            title: SaveConfirmationAlert.title,
            message: SaveConfirmationAlert.message,
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(
            title: SaveConfirmationAlert.yesActionTitle,
            style: .default
        ) { _ in
            self.saveAndDismiss()
        }
        let noAction = UIAlertAction(
            title: SaveConfirmationAlert.noActionTitle,
            style: .cancel
        )
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func confirmCancel() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let yesAction = UIAlertAction(
            title: CancelConfirmationAlert.yesActionTitle,
            style: .destructive
        ) { _ in
            self.delegate?.activityDetailViewControllerDidCancel(self)
        }
        let noAction = UIAlertAction(
            title: CancelConfirmationAlert.noActionTitle,
            style: .cancel
        )
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        alert.pruneNegativeWidthConstraints()  // workaround to circumvent a UIKit bug
        present(alert, animated: true, completion: nil)
    }
    
    private func saveAndDismiss() {
        activityRepository.update(activity: activity)
        delegate?.activityDetailViewControllerDidFinish(self)
    }
    
    private func updateViewForEditing(_ editing: Bool) {
        rootView.nameField.isEnabled = editing
        rootView.descriptionTextView.isUserInteractionEnabled = editing
        rootView.doneSwitch.isEnabled = editing
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

    public override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        // Preserve the activity ID and editing state only if we are editing an existing activity.
        if activityDetailStrategy is ExistingActivityStrategy {
            coder.encode(activity.id, forKey: Restoration.Key.activityID)
            coder.encode(isEditing, forKey: Restoration.Key.activityDetailViewControllerIsEditing)
        }
        
        // Write out any temporary data if editing is in progress.
        if activityBuilder.hasChanges() {
            coder.encode(activityBuilder.hasChanges(),
                forKey: Restoration.Key.activityHasUnsavedChanges)
            coder.encode(activityBuilder.name, forKey: Restoration.Key.editedName)
            coder.encode(activityBuilder.description, forKey: Restoration.Key.editedDescription)
            coder.encode(activityBuilder.status.rawValue, forKey: Restoration.Key.editedStatus)
        }
        
        // Keep track of the active field.
        if rootView.nameField.isFirstResponder {
            coder.encode(Int32(1), forKey: Restoration.Key.activeField)
            
        } else if rootView.descriptionTextView.isFirstResponder {
            coder.encode(Int32(2), forKey: Restoration.Key.activeField)
            
        } else {
            coder.encode(Int32(0), forKey: Restoration.Key.activeField)  // No field was active
        }
    }

    public override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        // Decode the editing state only if we were editing an existing activity.
        if activityDetailStrategy is ExistingActivityStrategy {
            wasEditing = coder.decodeBool(
                forKey: Restoration.Key.activityDetailViewControllerIsEditing)
        }
        
        // Restore any unsaved data if editing was in progress.
        let activityHasUnsavedChanges =
            coder.decodeBool(forKey: Restoration.Key.activityHasUnsavedChanges)
        
        if activityHasUnsavedChanges {
            if let name = coder.decodeObject(forKey: Restoration.Key.editedName) as? String {
                activityBuilder.name = name
            }
            if let description = coder.decodeObject(forKey: Restoration.Key.editedDescription)
               as? String {
                activityBuilder.description = description
            }
            let rawStatus = coder.decodeInteger(forKey: Restoration.Key.editedStatus)
            if let status = Activity.Status(rawValue: rawStatus) {
                activityBuilder.status = status
            }
        }

        // Decode the identity of the last active field (if any).
        let activeField = coder.decodeInteger(forKey: Restoration.Key.activeField)
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

        if let activityID = coder.decodeObject(forKey: Restoration.Key.activityID) as? String,
           let activity = GlobalToDoListActivityRepository.activity(fromIdentifier: activityID) {
            return self.init(activity: activity,
                             activityRepository: GlobalToDoListActivityRepository)
        } else {
            return self.init(activity: nil,
                             activityRepository: GlobalToDoListActivityRepository)
        }
    }
}

// MARK: - Constants
extension ActivityDetailViewController {
    
    struct Restoration {
        static let viewControllerIdentifier = String(describing: ActivityDetailViewController.self)
        
        struct Key {
            static let activityID                              = "activityID"
            static let activityDetailViewControllerIsEditing   = "activityDetailViewControllerIsEditing"
            static let activityHasUnsavedChanges               = "activityHasUnsavedChanges"
            static let editedName                              = "editedName"
            static let editedDescription                       = "editedDescription"
            static let editedStatus                            = "editedStatus"
            static let activeField                             = "activeField"
        }
    }
    
    struct SaveConfirmationAlert {
        static let title            = "Confirmation"
        static let message          = "Are you sure?"
        static let yesActionTitle   = "Yes"
        static let noActionTitle    = "No"
    }
    
    struct CancelConfirmationAlert {
        static let yesActionTitle   = "Discard Changes"
        static let noActionTitle    = "Cancel"
    }
}
