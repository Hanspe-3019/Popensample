//
//  LogStats.swift
//  Popensample
//
//  Created by Hans-Peter   on 08.02.23.
//

import Foundation

final class LogStats {
    
    let saveHandle: FileHandle?
    var stats: [StatsKey: StatsValue] = [:]
    var eventCount = 0
    
    init(_ outputDirectory: URL?) {
        guard let directory = outputDirectory else {
            saveHandle = nil
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let suffix = formatter.string(from: Date())
        let saveURL = directory.appending(component: "logstats-\(suffix).txt")
        guard FileManager.default.createFile(atPath: saveURL.path(), contents: nil) else {
            print("Could not create \(saveURL.path)")
            saveHandle = nil
            return
        }
        
        do {
            saveHandle = try FileHandle(forWritingTo: saveURL)
        } catch {
            saveHandle = nil
        }
    }
    
    func add(_ logrec: LogRecord, showProgress: Bool) {
        if eventCount == 0 {
            print("")
        }
        eventCount += 1
        let key = StatsKey(logrec)
        if stats[key] == nil {
            stats[key] = StatsValue()
        }
        stats[key]?.add(size: logrec.eventMessage.count)
    
        if showProgress && eventCount % 100 == 0 {
            print(
                "...processed \(eventCount) events, max BufferLength \(LineBuffer.maxLength)",
                terminator: "\r")
            LineBuffer.resetCurrentLength()
            fflush(__stdoutp)

        }
        
    }
    func write() {
        Self.logInfo("Start writing")
        defer {
            Self.logInfo("Finished writing")
        }
        guard saveHandle == nil else {
            saveStats()
            return
        }
        stats.sorted { (lhs, rhs) -> Bool in
            lhs.key < rhs.key
        } .forEach {
            print("\($0.key.paddedKey()) : \($0.value.formatted())")
        }
    }
    func saveStats() {
        
        guard let saveHandle = saveHandle else {
            fatalError("Logic Error")
        }
        
        do {
            try stats.forEach {
                if let line = "\($0.key),\($0.value.formattedForSave())\n".data(using: .utf8) {
                    try saveHandle.write(contentsOf: line)
                }
            }
        } catch {
            print(error)
        }
        
    }
}
