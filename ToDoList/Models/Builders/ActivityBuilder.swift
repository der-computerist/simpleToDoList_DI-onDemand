//
//  ActivityBuilder.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 7/12/22.
//

import Foundation

private typealias ActivityDetails = (name: String, description: String, status: Activity.Status)

public struct ActivityBuilder {
    
    private struct Constants {
        static let nameMaxCharacters = 50
        static let descriptionMaxCharacters = 200
    }

    // MARK: - Properties
    public var name: String
    public var description: String
    public var status: Activity.Status
    private let id: ActivityID
    private let dateCreated: Date
    private let originalActivityDetails: ActivityDetails
    
    // MARK: - Object lifecycle
    public init(activity: Activity?) {
        
        if let name = activity?.name,
           let description = activity?.description,
           let status = activity?.status,
           let id = activity?.id,
           let dateCreated = activity?.dateCreated {
            
            // Existing activity
            self.name = name
            self.description = description
            self.status = status
            self.id = id
            self.dateCreated = dateCreated
            
        } else {
            // New activity
            self.name = ""
            self.description = ""
            self.status = .pending
            self.id = UUID().uuidString
            self.dateCreated = Date()
        }
        
        originalActivityDetails = (self.name, self.description, self.status)
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
    
    // MARK: - Activity Creation Error
    public enum Error: Swift.Error {
        case nameEmpty
        case nameTooLong(maxCharacters: Int)
        case descriptionTooLong(maxCharacters: Int)
    }
}

// MARK: Public
extension ActivityBuilder.Error {
    
    public static let title = NSLocalizedString(
        "Activity Creation Error",
        comment: "ActivityCreationError.title"
    )
}

// MARK: LocalizedError
extension ActivityBuilder.Error: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .nameEmpty:
            return NSLocalizedString(
                "Activity name can't be empty.",
                comment: "ActivityCreationError.nameEmpty"
            )
            
        case let .nameTooLong(maxCharacters):
            let description = NSLocalizedString(
                "Activity name exceeds max characters (%d).",
                comment: "ActivityCreationError.nameTooLong"
            )
            return String.localizedStringWithFormat(description, maxCharacters)
            
        case let .descriptionTooLong(maxCharacters):
            let description = NSLocalizedString(
                "Activity description exceeds max characters (%d).",
                comment: "ActivityCreationError.descriptionTooLong"
            )
            return String.localizedStringWithFormat(description, maxCharacters)
        }
    }
}
