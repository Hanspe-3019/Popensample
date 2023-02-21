//
//  LogStats+KeyValue.swift
//  logdreamer
//
//  Created by Hans-Peter on 13.02.23.
//

import Foundation

/// Kombination aus process, messageType, subsystem und category
struct StatsKey: Hashable, CustomStringConvertible, Comparable {
    static func < (lhs: StatsKey, rhs: StatsKey) -> Bool {
        "\(lhs)" < "\(rhs)"
    }
    
    var description: String {
        """
        "\(process)","\(messageType)","\(subsystem)","\(category)","\(eventType)"
        """
    
}
    
    let subsystem: String
    let category: String
    let messageType: String
    let process: String
    let eventType: String
    
    static var subsystemWidth = -1
    static var categoryWidth = -1
    static var messageTypeWidth = -1
    static var processWidth = -1
    static var eventTypeWidth = -1
    
    init(_ logrec: LogRecord) {
        if let c = logrec.subsystem?.count, c > 0 {
            subsystem = logrec.subsystem!
        } else {
            subsystem = "-"
        }
        Self.subsystemWidth = max(Self.subsystemWidth, subsystem.count)
        
        if let c = logrec.category?.count, c > 0 {
            category = logrec.category!
        } else {
            category = "-"
        }
        Self.categoryWidth = max(Self.categoryWidth, category.count)
        messageType = logrec.messageType ?? "-"
        Self.messageTypeWidth = max(Self.messageTypeWidth, messageType.count)
        process = logrec.process
        Self.processWidth = max(Self.processWidth, process.count)
        if let c = logrec.eventType?.count, c > 0 {
            eventType = logrec.eventType!
        } else {
            eventType = "-"
        }
        Self.eventTypeWidth = max(Self.eventTypeWidth, eventType.count)
    }
    
    /// Ausrichtung der Felder im Key durch Auffüllen mit Spaces entsprechend der maximal beobachteten Länge des Feldinhaltes
    /// - Returns: Joined Properties padded with spaces as String
    func paddedKey() -> String {
        let pad = " "
        return [
            process.padding(toLength: Self.processWidth, withPad: pad, startingAt: 0),
            messageType.padding(toLength: Self.messageTypeWidth, withPad: pad, startingAt: 0),
            subsystem.padding(toLength: Self.subsystemWidth, withPad: pad, startingAt: 0),
            category.padding(toLength: Self.categoryWidth, withPad: pad, startingAt: 0),
            eventType.padding(toLength: Self.eventTypeWidth, withPad: pad, startingAt: 0),
        ].joined(separator: " ")

    }
}
/// Hält die Anzahl der jeweiligen Key-Werte und die Summe von deren Message-Längen
struct StatsValue {
    var itsCount = 0
    var sumSize = 0
    mutating func add(size: Int) {
        itsCount += 1
        sumSize += size
    }
    func formatted() -> String {
        let count = String(format: "%5d", self.itsCount)
        let sizeAvg = String(format: "%6.1f", Double(sumSize) / Double(self.itsCount) )
        return "\(count)  \(sizeAvg)"
    }
    func formattedForSave() -> String {
        return "\(itsCount),\(sumSize)"
    }
}
