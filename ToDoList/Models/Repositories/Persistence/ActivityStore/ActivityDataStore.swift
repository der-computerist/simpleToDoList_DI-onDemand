//
//  ActivityDataStore.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import Foundation

@objc
public protocol ActivityDataStore {
    
    @objc dynamic var activities: [Activity] { get }
    @objc dynamic var activitiesCount: Int { get }
    
    func update(activity: Activity, completion: ((Activity) -> Void)?)
    func delete(activity: Activity, completion: ((Activity) -> Void)?)
    func save() throws
}

extension ActivityDataStore {
    
    public func activity(fromIdentifier activityID: ActivityID) -> Activity? {
        let filteredActivities = activities.filter({ $0.id == activityID })
        if filteredActivities.isEmpty { return nil }
        return filteredActivities.first
    }
}
