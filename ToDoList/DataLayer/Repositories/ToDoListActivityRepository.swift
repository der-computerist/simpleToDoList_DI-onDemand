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
    public var allActivities: [Activity] {
        dataStore.allActivities
    }
    public var emptyActivity: Activity {
        Activity()
    }
    private let dataStore: ActivityDataStore
    
    // MARK: - Methods
    public init(dataStore: ActivityDataStore) {
        self.dataStore = dataStore
    }
    
    public func save(activity: Activity, completion: ((Activity) -> Void)?) {
        dataStore.save(activity: activity, completion: completion)
    }
    
    public func delete(activity: Activity, completion: ((Activity) -> Void)?) {
        dataStore.delete(activity: activity, completion: completion)
    }
    
    public func saveChanges() -> Bool {
        dataStore.saveChanges()
    }
}
