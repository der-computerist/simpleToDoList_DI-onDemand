//
//  FileActivityDataStore.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/5/22.
//

import Foundation

public class FileActivityDataStore: ActivityDataStore {

    // MARK: - Properties
    private let fileName = Constants.fileName

    // MARK: - Methods
    public func readActivities() -> [Activity] {
        if let activities = try? DiskCaretaker.retrieve([Activity].self, from: fileName) {
            return activities
        }
        return []
    }
    
    public func save(activities: [Activity]) throws {
        do {
            try DiskCaretaker.save(activities, to: fileName)
            print("ALL ACTIVITIES SAVED!")
        } catch {
            print("ERROR: Could not save the activities :(")
            throw error
        }
    }
}

// MARK: - Constants
extension FileActivityDataStore {
    
    struct Constants {
        static let fileName = "activities"
    }
}
