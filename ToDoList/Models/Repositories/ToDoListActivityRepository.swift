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
    public private(set) lazy var activities: [Activity] = dataStore.activities
    @objc public private(set) dynamic lazy var activitiesCount = calculateActivitiesCount()

    private let dataStore: NSObject & ActivityDataStore
    private lazy var kvoActivities = mutableArrayValue(forKey: #keyPath(activities))
    private var activitiesObservation: NSKeyValueObservation?
    private var activitiesCountObservation: NSKeyValueObservation?
    
    // MARK: - Object lifecycle
    public init(dataStore: NSObject & ActivityDataStore) {
        self.dataStore = dataStore
        super.init()
        activitiesObservation = observeActivities(on: dataStore)
        activitiesCountObservation = observeActivitiesCount(on: dataStore)
    }
    
    // MARK: - Methods
    public func activity(fromIdentifier activityID: ActivityID) -> Activity? {
        dataStore.activity(fromIdentifier: activityID)
    }
    
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
    
    private func observeActivities<T: NSObject & ActivityDataStore>(
        on subject: T
    ) -> NSKeyValueObservation {
        
        subject.observe(\.activities, options: .new) { [weak self] subject, change in
            switch change.kind {
            case .insertion:
                guard let newActivities = change.newValue,
                      let newActivity = newActivities.first else { return }
                self?.kvoActivities.add(newActivity)
            case .removal:
                guard let index = change.indexes?.first else { return }
                self?.kvoActivities.removeObject(at: index)
            case .replacement:
                guard let index = change.indexes?.first,
                      let newActivity = change.newValue?.first else { return }
                self?.kvoActivities[index] = newActivity
            default:
                self?.activities = subject.activities
            }
        }
    }

    private func observeActivitiesCount<T: NSObject & ActivityDataStore>(
        on subject: T
    ) -> NSKeyValueObservation {
        
        subject.observe(\.activitiesCount, options: .new) { [weak self] subject, _ in
            self?.activitiesCount = subject.activitiesCount
        }
    }
}
