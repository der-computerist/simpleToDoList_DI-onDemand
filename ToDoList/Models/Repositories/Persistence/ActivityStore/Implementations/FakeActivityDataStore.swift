//
//  FakeActivityDataStore.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/28/22.
//

import Foundation

public class FakeActivityDataStore: ActivityDataStore {
    
    public func readActivities() -> [Activity] {
        print("Try to read activities from fake disk...")
        print("  simulating read action...")
        return [Activity(name: "Play Forza Horizon 5",
                         description: "On the Xbox Series X",
                         status: .pending,
                         id: UUID().uuidString,
                         dateCreated: Date()),
                Activity(name: "Play Super Mario Odyssey",
                         description: "On the Nintendo Switch",
                         status: .pending,
                         id: UUID().uuidString,
                         dateCreated: Date()),
                Activity(name: "Play The Last of Us Part I",
                         description: "On the PlayStation 5",
                         status: .pending,
                         id: UUID().uuidString,
                         dateCreated: Date()),
                Activity(name: "Play Grand Theft Auto V",
                         description: "On the Xbox Series X",
                         status: .done,
                         id: UUID().uuidString,
                         dateCreated: Date()),
                Activity(name: "Play Metroid Dread",
                         description: "On the Nintendo Switch",
                         status: .done,
                         id: UUID().uuidString,
                         dateCreated: Date())]
    }
    
    public func save(activities: [Activity]) throws {
        print("Try to save activities into fake disk...")
        print("  simulating save action...")
        print("  ALL ACTIVITIES SAVED!")
    }
}
