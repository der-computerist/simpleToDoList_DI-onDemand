//
//  DiskCaretaker.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 6/16/22.
//

import Foundation

public final class DiskCaretaker {
    
    // MARK: - Type properties
    public static let encoder = PropertyListEncoder()
    public static let decoder = PropertyListDecoder()
    
    // MARK: - Type methods
    public static func save<T: Codable>(_ object: T, to fileName: String) throws {
        do {
            let url = createDocumentURL(withFileName: fileName)
            let data = try encoder.encode(object)
            try data.write(to: url, options: .atomic)
            print("Save success: URL: `\(url)`")
            
        } catch let error {
            print("Save failed: Object: `\(object)`, Error: `\(error)`")
            throw error
        }
    }
    
    public static func retrieve<T: Codable>(_ type: T.Type, from fileName: String) throws -> T {
        let url = createDocumentURL(withFileName: fileName)
        do {
            let data = try Data(contentsOf: url)
            let object = try decoder.decode(type, from: data)
            print("Retrieve success: URL: `\(url)`")
            return object
            
        } catch let error {
            print("Retrieve failed: URL: `\(url)`, Error: `\(error)`")
            throw error
        }
    }
    
    public static func createDocumentURL(withFileName fileName: String) -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent(fileName).appendingPathExtension("plist")
    }
}
