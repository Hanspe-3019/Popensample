//
//  LogStreamer+run.swift
//  Popensample
//
//  Created by Hans-Peter   on 09.02.23.
//

import Foundation
import ArgumentParser

extension LogStreamer {
    func run() throws {
       
        Self.logInfo("Start running")
        defer {
            Self.logInfo("Stop running")
        }
        
        let outputDirectory = Self.validateOutputDirectory(saveToDir)
        if saveToDir != nil && outputDirectory == nil {
            throw ValidationError("--output: \(saveToDir!) path invalid, not an existing directory!")
        }
        let logstats = LogStats(outputDirectory)
        let lrs: LogRecorddSave?
        if let outputDirectory = outputDirectory, dumpMessages {
            lrs = LogRecorddSave(outputDirectory)
        } else {
            lrs = nil
        }
        let showProgress = lrs != nil || !dumpMessages
        
        let logProcess = Process()

        logProcess.executableURL = URL(filePath: "/usr/bin/log")
        
        logProcess.arguments = buildArgForStream()
        let logStream = Pipe()
        logProcess.standardOutput = logStream
        
        func signalHandler () {
            Self.logInfo("received signal to terminate")
            logProcess.terminate()
            logstats.write()
            
            Self.exit()
        }
        
        let sourceSignals = setupSourceSignals(
            sig: [SIGTERM, SIGINT],
            handler: signalHandler
        )
        var logBuffer = LineBuffer()
        
        logStream.fileHandleForReading.readabilityHandler = { (fileHandle) -> Void in
            if let lines = logBuffer.append(fileHandle.availableData)?.split(separator: "\n") {
                for line in lines {
                    let line = String(line)
                    guard line.starts(with: "{"),
                          line.count > 128,
                          let logRecord = LogRecord(line) else {
                        continue
                    }
                    
                    logstats.add(logRecord, showProgress: showProgress )
                    if dumpMessages {
                        if let lrs = lrs {
                            let _ = lrs.save(asJSON: line)
                        } else {
                            print(line) // as json object
                        }
                    }
                }
            }
        }

        do {
            try logProcess.run()
            Self.logInfo(
                "Starting [\(logProcess.processIdentifier)] log " + logProcess.arguments!.joined(separator: " ")
            )
        } catch {
            print(error)
            throw ExitCode.failure
        }

        logProcess.waitUntilExit()
        let rc = logProcess.terminationStatus

        Self.logInfo("log stream ended rc=\(rc), \(logstats.eventCount) log messages")
        if rc != 0 {
            throw ExitCode.failure
        }

        logstats.write()
        // Dummy test, um warning zu vermeiden
        if sourceSignals.count != 2 {
            Self.exit()
        }
           
    }
    
    func setupSourceSignals(
        sig: [Int32],
        handler: @escaping () -> ()
    ) -> [DispatchSourceSignal] {
        
        sig.forEach { signal($0, SIG_IGN) }
        let sourceSignals = sig .map {
            DispatchSource.makeSignalSource(signal: $0, queue: .main)
            
        }
        for sourceSignal in sourceSignals {
            sourceSignal.setEventHandler(handler: handler)
            sourceSignal.activate()
        }
        return sourceSignals
        
    }
    
    func buildArgForStream() -> [String] {
        
        // ndjson    Line-delimited JSON output.
        //     Event data is synthesized as JSON dictionaries, each emitted on a
        //     single line.  A trailing record, identified by the inclusion of a
        //     "finished" field, is emitted to indicate the end of events.
        //   logStreamProcess.arguments = "stream --style ndjson --timeout 1m --process Calendar"
        var logArgs: [String] = [
            "stream",
            "--no-backtrace",
            "--style", "ndjson",
            "--timeout", timeout,
        ]
        
        if type != nil {
            logArgs += ["--type", type!]
        }
        if level != nil {
            logArgs += ["--level", level!]
        }
        if predicate != nil {
            logArgs += ["--predicate", predicate!]
        }
        if process != nil {
            logArgs += ["--process", process!]
        }
        
        return logArgs
    }
    
    static func validateOutputDirectory(_ output : String?) -> URL? {
        guard let output = output else {
            return nil
        }
        let url = URL(filePath: output)
        if (
            try? url.resourceValues(forKeys: [.isDirectoryKey])
            )? .isDirectory ?? false {
                return url
        }
            
        return nil
    }
}
