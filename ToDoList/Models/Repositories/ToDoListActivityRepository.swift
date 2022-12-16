//
//  ToDoListActivityRepository.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/7/22.
//

import Foundation

public let GlobalToDoListActivityRepository: NSObject & ActivityRepository = {
    let activityDataStore = FileActivityDataStore()
    return ToDoListActivityRepository(dataStore: activityDataStore)
}()

public class ToDoListActivityRepository: NSObject, ActivityRepository {

    // MARK: - Properties
    public private(set) lazy var activities: [Activity] = dataStore.readActivities() {
        didSet {
            if activities.count != oldValue.count {
                updateActivitiesCount()
            }
        }
    }
    @objc public private(set) dynamic lazy var activitiesCount = calculateActivitiesCount()

    private let dataStore: ActivityDataStore
    
    /**
     Proxy to the `activities` array that allows the Key-Value Observing mechanism to
     communicate the kind of change to any observers.
     
     Any changes to the `activities` array must be made through this proxy; otherwise,
     KVO won't be able to detect the kind of change.
     */
    private lazy var kvoActivities = mutableArrayValue(forKey: #keyPath(activities))
    
    // MARK: - Object lifecycle
    public init(dataStore: ActivityDataStore) {
        self.dataStore = dataStore
    }
    
    // MARK: - Methods
    public func update(activity: Activity, completion: ((Activity) -> Void)?) {
        if let index = activities.firstIndex(of: activity) {
            // If the activity already exists, update it
            kvoActivities[index] = activity
            print("Activity updated!")
        } else {
            // Otherwise, add to the end of the array
            kvoActivities.add(activity)
            print("New activity registered!")
        }
        completion?(activity)
        try? dataStore.save(activities: activities)
    }
    
    public func delete(activity: Activity, completion: ((Activity) -> Void)?) {
        guard let index = activities.firstIndex(of: activity) else { return }
        kvoActivities.removeObject(at: index)
        print("Activity deleted!")
        completion?(activity)
        try? dataStore.save(activities: activities)
    }
    
    public func activity(fromIdentifier activityID: ActivityID) -> Activity? {
        let filteredActivities = activities.filter({ $0.id == activityID })
        if filteredActivities.isEmpty { return nil }
        return filteredActivities.first
    }
    
    // MARK: Private
    private func calculateActivitiesCount() -> Int {
        activities.count
    }
    
    private func updateActivitiesCount() {
        activitiesCount = activities.count
    }
}
