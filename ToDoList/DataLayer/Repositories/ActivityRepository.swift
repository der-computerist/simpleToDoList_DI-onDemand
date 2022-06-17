//
//  ActivityRepository.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import Foundation

public protocol ActivityRepository {
    
    var activities: [Activity] { get }
    var emptyActivity: Activity { get }
    func update(activity: Activity, completion: ((Activity) -> Void)?)
    func delete(activity: Activity, completion: ((Activity) -> Void)?)
    func save() throws
}
