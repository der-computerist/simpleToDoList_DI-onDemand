//
//  ActivityCreationError.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 2/9/22.
//

import Foundation

enum ActivityCreationError: Error {
    case nameEmpty
    case nameTooLong(maxCharacters: Int)
    case descriptionTooLong(maxCharacters: Int)
}

// MARK: - LocalizedError

extension ActivityCreationError: LocalizedError {
    var errorDescription: String? {
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

// MARK: - Public

extension ActivityCreationError {
    public static let title = NSLocalizedString(
        "Activity Creation Error",
        comment: "ActivityCreationError.title"
    )
}
