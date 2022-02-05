//
//  Activity.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/11/21.
//

import Foundation

public typealias ActivityID = String

public class Activity: Codable {
    
    // MARK: - Properties
    public let id: ActivityID
    public var name: String
    public var activityDescription: String?
    public let dateCreated: Date
    
    // MARK: - Methods
    public init(name: String, description: String? = nil) {
        id = UUID().uuidString
        self.name = name
        activityDescription = description
        dateCreated = Date()
    }

    public convenience init() {
        self.init(name: "")
    }
}

extension Activity: Equatable {
    
    public static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Activity: CustomStringConvertible {
    
    public var description: String {
        let referenceType = type(of: self)
        let properties: [String: Any] =
            [
                "id": id,
                "name": name,
                "activityDescription": activityDescription ?? "",
                "dateCreated": String(describing: dateCreated)
            ]
        return "<\(referenceType): \(properties as AnyObject)>"
    }
}
