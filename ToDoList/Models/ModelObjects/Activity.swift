//
//  Activity.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/11/21.
//

import Foundation

public typealias ActivityID = String

public struct Activity: Codable {
    
    public enum Status: Int, Codable {
        case pending = 0
        case done = 1
    }

    // MARK: - Properties
    public let name: String
    public let description: String?
    public let status: Status
    public let id: ActivityID
    public let dateCreated: Date
}

// MARK: - Equatable
extension Activity: Equatable {
    
    public static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}
