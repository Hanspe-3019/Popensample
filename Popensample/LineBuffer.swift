//
//  LineBuffer.swift
//  Popensample
//
//  Created by Hans-Peter   on 09.02.23.
//

import Foundation

struct LineBuffer {
    // https://www.objc.io/blog/1019/04/30/reading-from-standard-input-output/
    static let newline = UInt8(ascii: "\n")
    private var buffer = Data(capacity: 1024 * 64)
    static var notUsed = true
    mutating func append(_ data: Data) -> String? {
        if Self.notUsed {
            Self.notUsed = false
            Self.logDebug("Start")
        }
        buffer.append(data)
        if buffer.last == Self.newline {
            guard let string = String(data: buffer, encoding: .utf8) else {
                fatalError()
            }
            buffer.removeAll(keepingCapacity: true)
            return string
        }
        if buffer.count > 60 * 1024 {
            Self.logDebug("flush head buffer \(buffer.count)")
            guard
                let atNewline = buffer.lastIndex(of: Self.newline),
                let string = String(data: buffer[0...atNewline], encoding: .utf8)
            else {
                fatalError("no newline")
            }
            let trailingData = buffer[atNewline.advanced(by: 1)...]
            assert( trailingData.first! == UInt8(ascii: "{") )
            buffer.removeAll(keepingCapacity: true)
            buffer.append(trailingData)
            return string
                
        }
        return nil
    }
}
