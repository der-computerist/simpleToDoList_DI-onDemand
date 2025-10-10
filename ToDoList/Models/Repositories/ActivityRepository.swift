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

    func updateOrAdd(activity: Activity)
    func delete(activity: Activity)
    func activity(fromIdentifier activityID: ActivityID) -> Activity?
}
