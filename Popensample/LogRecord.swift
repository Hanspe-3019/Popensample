//
//  LogRecord.swift
//  Popensample
//
//  Created by Hans-Peter   on 06.02.23.
//

import Foundation


struct LogRecord: Decodable, CustomStringConvertible {
    var description: String {
        """
        
        ===== \(timestamp) =====
        subsystem: \(subsystem ?? "-")
        category: \(category ?? "-")
        processID: \(processID)
        messageType: \(messageType ?? "-")
        message: \(message)
        process: \(process)
        sender: \(sender)
        =====
        """
    }
    
    let timestamp: Date
    let subsystem: String?
    let category: String?
    let eventType: String?
    let eventMessage: String
    let processImagePath: String?
    let senderImagePath: String?
    let messageType: String?
    let processID: Int
    var initSize : Int? = -1
    
    var sender: String {
        trimPath(senderImagePath)
    }
    var process: String {
        trimPath(processImagePath)
    }
    var message: String {
        trimMessage(eventMessage)
    }
    static let decoder = makeDecoder()
    
    init?(_ jsonString: String) {
        let jsonData = jsonString.data(using: .utf8)!
        do {
            self = try Self.decoder.decode(LogRecord.self, from: jsonData)
        } catch {
            print("""
            +++ Err \(error)
            ++>
            \(jsonString)
            <++
            """)
            return nil
        }

    }

}
fileprivate func makeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    //                              "2023-02-06 12:20:35.414429+0100"
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSz"
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    return decoder
}
fileprivate func trimPath( _ path: String?) -> String {
    guard let path = path else {
        return "-"
    }
    guard let lastSlash = path.lastIndex(of: "/") else {
        return path
    }
    return String(
        path.suffix(
            from: path.index(after: lastSlash)
        )
    )
    
}
fileprivate func trimMessage(_ msg: String) -> String {
    guard msg.count > 64 else {
        return msg
    }
    return String(msg.prefix(61)) + "..."
}
