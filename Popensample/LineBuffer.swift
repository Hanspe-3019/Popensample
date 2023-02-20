//
//  LineBuffer.swift
//  Popensample
//
//  Created by Hans-Peter   on 09.02.23.
//

import Foundation

struct LineBuffer {
    // https://www.objc.io/blog/1019/04/30/reading-from-standard-input-output/
    private var buffer = Data()
    static var maxLength = 0
    static var lastLength = 0
    mutating func append(_ data: Data) -> String? {
        buffer.append(data)
        if let string = String(data: buffer, encoding: .utf8),
           string.last?.isNewline == true {
            Self.lastLength = max(Self.lastLength, buffer.count)
            
            buffer.removeAll()
            return string
        }
        return nil
    }
    static func resetCurrentLength() {
        Self.maxLength = max(Self.maxLength, Self.lastLength)
        Self.lastLength = 0
        return
    }
}
