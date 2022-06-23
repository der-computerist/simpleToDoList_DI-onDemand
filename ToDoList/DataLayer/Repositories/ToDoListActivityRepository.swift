//
//  ToDoListActivityRepository.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/7/22.
//

import Foundation

public let GlobalToDoListActivityRepository: ActivityRepository = {
    let activityDataStore = FileActivityDataStore()
    return ToDoListActivityRepository(dataStore: activityDataStore)
}()

public class ToDoListActivityRepository: ActivityRepository {

    // MARK: - Properties
    public var activities: [Activity] {
        dataStore.activities
    }
    private let dataStore: ActivityDataStore
    
    // MARK: - Object lifecycle
    public init(dataStore: ActivityDataStore) {
        self.dataStore = dataStore
    }
    
    // MARK: - ActivityRepository
    public func emptyActivity() -> Activity {
        Activity()
    }
    
    public func update(activity: Activity, completion: ((Activity) -> Void)?) {
        dataStore.update(activity: activity, completion: completion)
    }
    
    public func delete(activity: Activity, completion: ((Activity) -> Void)?) {
        dataStore.delete(activity: activity, completion: completion)
    }
    
    public func save() throws {
        try dataStore.save()
    }
}
