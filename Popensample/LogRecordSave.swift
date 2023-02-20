//
//  LogRecordSave.swift
//  logsteamer
//
//  Created by Hans-Peter   on 11.02.23.
//

import Foundation
final class LogRecorddSave {
    
    var saveEventsHandle: FileHandle?
    
    init(_ directory: URL) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let suffix = formatter.string(from: Date())
        let saveURL = directory.appending(
            component: "logmsgs-\(suffix).json"
        )
        
        guard
            FileManager.default.createFile(atPath: saveURL.path(),
            contents: nil) else {
            
            print("Could not create \(saveURL.path)")
            saveEventsHandle = nil
            return
        }
        
        do {
            saveEventsHandle = try FileHandle(forWritingTo: saveURL)
        } catch {
            saveEventsHandle = nil
        }
    }
    func save(asJSON str: String)  -> Bool {
        let str = "\(str)\n"
        if let line = str.data(using: .utf8) {
            do {
                try saveEventsHandle?.write(contentsOf: line)
                return true
            } catch {
                print(error)
            }
        }
        return false
    }
    
}
