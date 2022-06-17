//
//  FileActivityDataStore.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/5/22.
//

import Foundation

public class FileActivityDataStore: ActivityDataStore {

    // MARK: - Properties
    public private(set) var activities = [Activity]()
    private let fileName = "activities"

    // MARK: - Object lifecycle
    public init() {
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
    
    public func save() -> Bool {
        do {
            try DiskCaretaker.save(activities, to: fileName)
            return true
        } catch {
            return false
        }
    }
}
