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
    public var activities: [Activity] {
        dataStore.activities
    }
    @objc public dynamic lazy var activitiesCount = calculateActivitiesCount()

    private let dataStore: NSObject & ActivityDataStore
    private var activitiesCountObservation: NSKeyValueObservation?
    
    // MARK: - Object lifecycle
    public init(dataStore: NSObject & ActivityDataStore) {
        self.dataStore = dataStore
        super.init()
        activitiesCountObservation = observeActivitiesCount(on: dataStore)
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

    private func observeActivitiesCount<T: NSObject & ActivityDataStore>(
        on subject: T
    ) -> NSKeyValueObservation {
        
        subject.observe(\.activitiesCount, options: .new) { [weak self] subject, _ in
            self?.activitiesCount = subject.activitiesCount
        }
    }
}
