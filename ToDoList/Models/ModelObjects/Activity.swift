//
//  Activity.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/11/21.
//

import Foundation

public typealias ActivityID = String

public class Activity: NSObject, Codable {
    
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
    
    // MARK: - Methods
    init(name: String, description: String?, status: Status, id: ActivityID, dateCreated: Date) {
        self.name = name
        self.activityDescription = description
        self.status = status
        self.id = id
        self.dateCreated = dateCreated
    }
}

// MARK: - Equality
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
