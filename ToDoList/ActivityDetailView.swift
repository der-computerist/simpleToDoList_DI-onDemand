//
//  ActivityDetailView.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 1/25/22.
//

public enum ActivityDetailView {
    
    case newActivity(Activity)
    case existingActivity(Activity)
    
    var activity: Activity {
        switch self {
        case let .newActivity(activity),
             let .existingActivity(activity):
            return activity
        }
    }
}

extension ActivityDetailView: Equatable {
    
    public static func == (lhs: ActivityDetailView, rhs: ActivityDetailView) -> Bool {
        switch (lhs, rhs) {
        case let (.newActivity(l), .newActivity(r)):
            return l == r
        case let (.existingActivity(l), .existingActivity(r)):
            return l == r
        case (.newActivity, _),
             (.existingActivity, _):
            return false
        }
    }
}
