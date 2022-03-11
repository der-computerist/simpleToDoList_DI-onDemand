//
//  Activity.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/11/21.
//

import Foundation

public typealias ActivityID = String

public enum ActivityStatus: Int, Codable {
    case pending = 0
    case done = 1
}

public struct Activity: Codable {
    
    // MARK: - Properties
    public let id: ActivityID
    public var name: String
    public var description: String?
    public let dateCreated: Date
    public var status: ActivityStatus
    
    // MARK: - Methods
    public init(name: String, description: String? = nil) {
        id = UUID().uuidString
        self.name = name
        self.description = description
        dateCreated = Date()
        status = .pending
    }

    public init() {
        self.init(name: "")
    }
}

extension Activity: Equatable {
    
    public static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}
