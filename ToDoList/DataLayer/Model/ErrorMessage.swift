//
//  ErrorMessage.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/29/22.
//

import Foundation

public struct ErrorMessage: Error {
    
    // MARK: - Properties
    public let id: UUID
    public let title: String
    public let message: String
    
    // MARK: - Methods
    public init(title: String, message: String) {
        self.id = UUID()
        self.title = title
        self.message = message
    }
}

extension ErrorMessage: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
