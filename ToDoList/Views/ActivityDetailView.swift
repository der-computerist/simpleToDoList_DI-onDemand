//
//  ActivityDetailView.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/25/22.
//

public enum ActivityDetailView {
    
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

extension ActivityDetailView: Equatable {
    
    public static func == (lhs: ActivityDetailView, rhs: ActivityDetailView) -> Bool {
        switch (lhs, rhs) {
        case (.newActivity, .newActivity):
            return true
        case let (.existingActivity(l), .existingActivity(r)):
            return l == r
        case (.newActivity, _),
             (.existingActivity, _):
            return false
        }
    }
}
