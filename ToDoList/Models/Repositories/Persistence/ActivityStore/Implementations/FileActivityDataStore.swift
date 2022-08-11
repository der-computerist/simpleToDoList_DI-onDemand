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
    @objc public dynamic lazy var activitiesCount = calculateActivitiesCount()
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
    public func update(activity: Activity, completion: ((Activity) -> Void)? = nil) {
        if let index = activities.firstIndex(of: activity) {
            // If the activity already exists, update it
            activities[index] = activity
        } else {
            // Otherwise, add to the end of the array
            activities.append(activity)
        }
        print("Activity registered!")
        completion?(activity)
    }
    
    public func delete(activity: Activity, completion: ((Activity) -> Void)? = nil) {
        if let index = activities.firstIndex(of: activity) {
            activities.remove(at: index)
        }
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
