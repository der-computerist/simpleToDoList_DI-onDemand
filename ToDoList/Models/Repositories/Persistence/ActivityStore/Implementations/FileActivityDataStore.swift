//
//  FileActivityDataStore.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/5/22.
//

import Foundation

public class FileActivityDataStore: NSObject, ActivityDataStore {

    // MARK: - Properties
    public private(set) var activities = [Activity]() {
        didSet {
            if activities.count != oldValue.count {
                updateActivitiesCount()
            }
        }
    }
    @objc public private(set) dynamic lazy var activitiesCount = calculateActivitiesCount()
    
    /**
     Proxy to the `activities` array that allows the Key-Value Observing mechanism to
     communicate the kind of change to any observers.
     
     Any changes to the `activities` array must be made through this proxy; otherwise,
     KVO won't be able to detect the kind of change.
     */
    private lazy var kvoActivities = mutableArrayValue(forKey: #keyPath(activities))
    
    private let fileName = "activities"

    // MARK: - Object lifecycle
    public override init() {
        super.init()
        loadActivities()
    }
    
    private func loadActivities() {
        if let activities = try? DiskCaretaker.retrieve([Activity].self, from: fileName) {
            self.activities = activities
        }
    }

    // MARK: - Methods
    public func activity(fromIdentifier activityID: ActivityID) -> Activity? {
        let filteredActivities = activities.filter({ $0.id == activityID })
        if filteredActivities.isEmpty { return nil }
        return filteredActivities.first
    }
    
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
    }
    
    public func delete(activity: Activity, completion: ((Activity) -> Void)?) {
        guard let index = activities.firstIndex(of: activity) else { return }
        kvoActivities.removeObject(at: index)
        print("Activity deleted")
        completion?(activity)
    }
    
    public func save() throws {
        do {
            try DiskCaretaker.save(activities, to: fileName)
            print("ALL ACTIVITIES SAVED!")
        } catch {
            print("ERROR: Could not save the activities :(")
            throw error
        }
    }

    // MARK: Private
    private func calculateActivitiesCount() -> Int {
        activities.count
    }
    
    private func updateActivitiesCount() {
        activitiesCount = activities.count
    }
}
