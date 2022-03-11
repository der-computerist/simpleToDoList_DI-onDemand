//
//  FileActivityDataStore.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/5/22.
//

import Foundation

public class FileActivityDataStore: ActivityDataStore {

    // MARK: - Properties
    private(set) public var allActivities = [Activity]()
    private var docsURL: URL? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        .first
    }
    private var activitiesArchiveURL: URL? {
        docsURL?.appendingPathComponent("activities.plist")
    }
    
    public init() {
        guard let activitiesArchiveURL = activitiesArchiveURL else {
            assertionFailure("Missing path to archive file")
            return
        }
        
        do {
            let data = try Data(contentsOf: activitiesArchiveURL)
            let decoder = PropertyListDecoder()
            let activities = try decoder.decode([Activity].self, from: data)
            allActivities = activities
            
        } catch {
            print("Error reading in saved activities: \(error)")
        }
    }

    // MARK: - Methods
    public func save(activity: Activity, completion: ((Activity) -> Void)? = nil) {
        if let index = allActivities.firstIndex(of: activity) {
            // If the activity already exists, update it
            allActivities[index] = activity
        } else {
            // Otherwise, add to the end of the array
            allActivities.append(activity)
        }
        print("Activity saved!")
        completion?(activity)
    }
    
    public func delete(activity: Activity, completion: ((Activity) -> Void)? = nil) {
        if let index = allActivities.firstIndex(of: activity) {
            allActivities.remove(at: index)
        }
        print("Activity deleted")
        completion?(activity)
    }
    
    public func saveChanges() -> Bool {
        guard let activitiesArchiveURL = activitiesArchiveURL else {
            assertionFailure("Missing path to archive file")
            return false
        }
        
        print("Saving activities to: \(activitiesArchiveURL)")
        
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(allActivities)
            try data.write(to: activitiesArchiveURL, options: [.atomic])
            return true
            
        } catch let encodingError {
            assertionFailure("Error encoding allActivities: \(encodingError)")
            return false
        }
    }
}
