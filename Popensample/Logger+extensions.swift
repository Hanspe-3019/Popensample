//
//  MyLogger.swift
//  logdreamer
//
//  Created by Hans-Peter on 20.02.23.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let logstreamer = Logger(subsystem: subsystem, category: "LogStreamer")
    static let logstats = Logger(subsystem: subsystem, category: "LogStats")
    static let linebuffer = Logger(subsystem: subsystem, category: "LineBuffer")
}

extension LogStreamer {
    
    static func logInfo(_ msg: String) {
        Logger.logstreamer.info("\(msg, privacy: .public)")
    }
}

extension LogStats {
    
    static func logInfo(_ msg: String) {
        Logger.logstats.info("\(msg, privacy: .public)")
    }
}

extension LineBuffer {
    
    static func logDebug(_ msg: String) {
        Logger.linebuffer.debug("\(msg, privacy: .public)")
        
    }
}
