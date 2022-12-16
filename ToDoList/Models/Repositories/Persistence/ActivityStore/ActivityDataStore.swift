//
//  ActivityDataStore.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import Foundation

public protocol ActivityDataStore {
    
    func readActivities() -> [Activity]
    func save(activities: [Activity]) throws
}
