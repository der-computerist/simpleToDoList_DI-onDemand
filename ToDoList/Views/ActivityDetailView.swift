//
//  ActivityDetailView.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/25/22.
//

import Foundation

public enum ActivityDetailView: Equatable {
    
    case newActivity
    case existingActivity(Activity)
    
    var activity: Activity? {
        switch self {
        case let .existingActivity(activity):
            return activity
        case .newActivity:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .existingActivity:
            return "Details"
        case .newActivity:
            return "New Activity"
        }
    }
    
    var hidesActivityStatus: Bool {
        switch self {
        case .existingActivity:
            return false
        case .newActivity:
            return true
        }
    }
    
    var enablesNameField: Bool {
        switch self {
        case .existingActivity:
            return false
        case .newActivity:
            return true
        }
    }
    
    var enablesDescriptionField: Bool {
        switch self {
        case .existingActivity:
            return false
        case .newActivity:
            return true
        }
    }
}
