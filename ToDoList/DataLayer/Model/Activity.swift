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
    public var name = ""
    public var description: String?
    public var status = ActivityStatus.pending
    public private(set) var id: ActivityID = UUID().uuidString
    public private(set) var dateCreated = Date()

    // MARK: - Methods
    public init() {}
    
    public init(name: String, description: String? = nil) {
        self.name = name
        self.description = description
    }
}

extension Activity: Equatable {
    
    public static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}
