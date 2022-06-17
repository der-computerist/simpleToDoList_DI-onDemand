//
//  Activity.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/11/21.
//

import Foundation

public struct Activity: Codable {
    
    public enum ActivityStatus: Int, Codable {
        case pending = 0
        case done = 1
    }
    
    public typealias ActivityID = String

    // MARK: - Properties
    public var name = ""
    public var description: String?
    public var status = ActivityStatus.pending
    public private(set) var id: ActivityID = UUID().uuidString
    public private(set) var dateCreated = Date()
}

// MARK: - Equatable
extension Activity: Equatable {
    
    public static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}
