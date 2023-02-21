//
//  main.swift
//  Popensample
//
//  Created by Hans-Peter   on 04.01.13.
//

import Foundation
import ArgumentParser

@main
struct LogStreamer: ParsableCommand {
    static let VERSION = "1.0.3"
    
    @Option(
        name: .shortAndLong,
        help: "Terminate streaming after timeout has elapsed, default 2s\nPassed unchecked to log command."
    )
    var timeout : String = "2s"
    
    @Flag(
        name: [.customLong("dump"), .customLong("dump-messages")],
        help: """
            Dump log messages as JSON objects
             - to stdout or
             - to file according to option --output.
            """
    )
    var dumpMessages = false
    
    @Option(
        name: [.short, .customLong("save")],
        help: """
            Save stats and log messages to the specified directory.
            Statistics as `logstats-<timestamp>.txt`
            Log messages as `logmsgs-<timestamp>.json`
            """
    )
    var saveToDir: String?
    
    @Option(
        name: [.customLong("pred"), .customLong("predicate")],
        help: """
            Predicates to filter, multiple predicates are ORed
            Passed unchecked to log command.
            """
    )
    var predicate: [String] = []
    
    @Option(
        name: [.customLong("proc"), .customLong("process")],
        help: """
            Only log messages from the specified process, multiple process options are ORed.
            Passed unchecked to log command.
            """
    )
    var process: [String] = []
    
    @Option(
        help: """
            Limit streaming to given event types (activity, log or trace).
            Default is all.
            Passed unchecked to log command.
            """
    )
    var type : [String] = []
    
    @Option(
        help: """
            Include events at, and below, the given level.
            Default is `default`. Expand with `info` or with `debug'.
            Passed unchecked to log command.
            """
    )
    var level : String?
    
    
    
    static let configuration = CommandConfiguration(
        commandName: URL(
            filePath: CommandLine.arguments[0]).lastPathComponent,
        abstract: LogStreamer.abstract,
        discussion: LogStreamer.discussion,
        version: "\(VERSION)"
    )
    
}

