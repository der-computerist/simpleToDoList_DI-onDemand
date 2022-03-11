//
//  ActivityRepository.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import Foundation

public protocol ActivityRepository {
    
    var allActivities: [Activity] { get }
    var emptyActivity: Activity { get }
    func save(activity: Activity, completion: ((Activity) -> Void)?)
    func delete(activity: Activity, completion: ((Activity) -> Void)?)
    func saveChanges() -> Bool
}
