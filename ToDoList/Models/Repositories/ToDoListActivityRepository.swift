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

public class ToDoListActivityRepository: NSObject, ActivityRepository {

    // MARK: - Properties
    public var activities: [Activity] {
        dataStore.activities
    }
    @objc public dynamic lazy var activitiesCount = calculateActivitiesCount()
    @objc private let dataStore: ActivityDataStore
    private var observation: NSKeyValueObservation?
    
    // MARK: - Object lifecycle
    public init(dataStore: ActivityDataStore) {
        self.dataStore = dataStore
        super.init()
        
        observation = observe(
            \.dataStore.activitiesCount,
            options: [.new]
        ) { [weak self] _, change in
            self?.activitiesCount = change.newValue!
        }
    }
    
    // MARK: - Methods
    public func update(activity: Activity, completion: ((Activity) -> Void)?) {
        dataStore.update(activity: activity, completion: completion)
        try? dataStore.save()
    }
    
    public func delete(activity: Activity, completion: ((Activity) -> Void)?) {
        dataStore.delete(activity: activity, completion: completion)
        try? dataStore.save()
    }
    
    // MARK: Private
    private func calculateActivitiesCount() -> Int {
        dataStore.activitiesCount
    }
}
