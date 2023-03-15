//
//  ActivityBuilder.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 7/12/22.
//

import Foundation

private typealias ActivityDetails = (name: String, description: String, status: Activity.Status)

public struct ActivityBuilder {
    
    // MARK: - Properties
    public var name: String
    public var description: String
    public var status: Activity.Status
    private let id: ActivityID
    private let dateCreated: Date
    private let originalActivityDetails: ActivityDetails
    
    // MARK: - Object lifecycle
    public init(activity: Activity) {
        name = activity.name
        description = activity.activityDescription ?? ""
        status = activity.status
        id = activity.id
        dateCreated = activity.dateCreated
        originalActivityDetails = (name, description, status)
    }
    
    // MARK: - Public
    public func hasChanges() -> Bool {
        (name, description, status) != originalActivityDetails
    }
    
    public func hasNameChanges() -> Bool {
        name != originalActivityDetails.name
    }
    
    // MARK: - Builder
    public func build() throws -> Activity {
        guard name.count > 0 else {
            throw Error.nameEmpty
        }
        guard name.count <= Constants.nameMaxCharacters else {
            throw Error.nameTooLong(maxCharacters: Constants.nameMaxCharacters)
        }
        guard description.count <= Constants.descriptionMaxCharacters else {
            throw Error.descriptionTooLong(maxCharacters: Constants.descriptionMaxCharacters)
        }
        
        return Activity(name: name,
                        description: description,
                        status: status,
                        id: id,
                        dateCreated: dateCreated)
    }
}

// MARK: - Activity Creation Error
extension ActivityBuilder {
    
    public enum Error: Swift.Error {
        case nameEmpty
        case nameTooLong(maxCharacters: Int)
        case descriptionTooLong(maxCharacters: Int)
        
        public static let title = Constants.errorTitle
    }
}

// MARK: LocalizedError
extension ActivityBuilder.Error: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .nameEmpty:
            return Constants.nameEmptyErrorDescription
            
        case let .nameTooLong(maxCharacters):
            let description = Constants.nameTooLongErrorDescription
            return String.localizedStringWithFormat(description, maxCharacters)
            
        case let .descriptionTooLong(maxCharacters):
            let description = Constants.descriptionTooLongErrorDescription
            return String.localizedStringWithFormat(description, maxCharacters)
        }
    }
}

// MARK: - Constants
extension ActivityBuilder {
    
    struct Constants {
        static let nameMaxCharacters = 50
        static let descriptionMaxCharacters = 200
    }
}

extension ActivityBuilder.Error {
    
    struct Constants {
        static let errorTitle = NSLocalizedString(
            "Activity Creation Error",
            comment: "ActivityCreationError.title"
        )
        static let nameEmptyErrorDescription = NSLocalizedString(
            "Activity name can't be empty.",
            comment: "ActivityCreationError.nameEmpty"
        )
        static let nameTooLongErrorDescription = NSLocalizedString(
            "Activity name exceeds max characters (%d).",
            comment: "ActivityCreationError.nameTooLong"
        )
        static let descriptionTooLongErrorDescription = NSLocalizedString(
            "Activity description exceeds max characters (%d).",
            comment: "ActivityCreationError.descriptionTooLong"
        )
    }
}
