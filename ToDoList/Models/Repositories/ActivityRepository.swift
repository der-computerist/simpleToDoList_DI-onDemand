//
//  ActivityRepository.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import Foundation

@objc
public protocol ActivityRepository {
    
    @objc dynamic var activities: [Activity] { get }
    @objc dynamic var activitiesCount: Int { get }

    func update(activity: Activity, completion: ((Activity) -> Void)?)
    func delete(activity: Activity, completion: ((Activity) -> Void)?)
    func activity(fromIdentifier activityID: ActivityID) -> Activity?
}

extension ActivityRepository {
    
    func update(activity: Activity) {
        update(activity: activity, completion: nil)
    }
    
    func delete(activity: Activity) {
        delete(activity: activity, completion: nil)
    }
}
