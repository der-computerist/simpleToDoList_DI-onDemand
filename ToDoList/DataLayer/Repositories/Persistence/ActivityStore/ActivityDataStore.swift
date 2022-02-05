//
//  ActivityDataStore.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import Foundation

public protocol ActivityDataStore {
    
    var allActivities: [Activity] { get }
    func save(activity: Activity, completion: ((Activity) -> Void)?)
    func delete(activity: Activity, completion: ((Activity) -> Void)?)
    func saveChanges() -> Bool
}
