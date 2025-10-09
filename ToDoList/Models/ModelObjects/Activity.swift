//
//  Activity.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/11/21.
//

import Foundation

public typealias ActivityID = String

public class Activity: NSObject, Codable {
    
    // MARK: - Nested types
    public enum Status: Int, Codable {
        case pending = 0
        case done = 1
    }
    
    // MARK: - Properties
    public let name: String
    public let activityDescription: String?
    public let status: Status
    public let id: ActivityID
    public let dateCreated: Date
    
    // MARK: - Initialization
    init(name: String, description: String?, status: Status, id: ActivityID, dateCreated: Date) {
        self.name = name
        self.activityDescription = description
        self.status = status
        self.id = id
        self.dateCreated = dateCreated
    }
    
    public static var emptyActivity: Activity {
        Activity(
            name: "",
            description: "",
            status: .pending,
            id: UUID().uuidString,
            dateCreated: Date()
        )
    }
}

// MARK: - Equatable
extension Activity {
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Activity {
            return self.id == other.id
        }
        return false
    }
}

// MARK: - CustomStringConvertible
extension Activity {
    
    public override var description: String {
        let referenceType = type(of: self)
        let properties: [String: Any] = [
            "name": name,
            "description": activityDescription as Any,
            "status": status,
            "id": id,
            "dateCreated": dateCreated
        ]
        return "<\(referenceType): \(properties as AnyObject)>"
    }
}
