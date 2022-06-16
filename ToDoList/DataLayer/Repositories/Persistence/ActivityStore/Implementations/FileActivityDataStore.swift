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
    private let fileName = "activities.plist"
    private var docsURL: URL? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        .first
    }
    private var activitiesArchiveURL: URL? {
        docsURL?.appendingPathComponent(fileName)
    }
    
    // MARK: - Object lifecycle
    public init() {
        loadActivities()
    }
    
    private func loadActivities() {
        guard let activitiesArchiveURL = activitiesArchiveURL else {
            assertionFailure("Missing path to archive file")
            return
        }
        
        do {
            let data = try Data(contentsOf: activitiesArchiveURL)
            let decoder = PropertyListDecoder()
            let activities = try decoder.decode([Activity].self, from: data)
            self.activities = activities
            
        } catch {
            print("Error reading in saved activities: \(error)")
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
        print("Activity saved!")
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
        guard let activitiesArchiveURL = activitiesArchiveURL else {
            assertionFailure("Missing path to archive file")
            return false
        }
        
        print("Saving activities to: \(activitiesArchiveURL)")
        
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(activities)
            try data.write(to: activitiesArchiveURL, options: [.atomic])
            return true
            
        } catch let encodingError {
            assertionFailure("Error encoding activities: \(encodingError)")
            return false
        }
    }
}
