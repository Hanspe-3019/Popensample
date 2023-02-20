//
//  LogStreamer+doc.swift
//  Popensample
//
//  Created by Hans-Peter   on 09.02.23.
//

import Foundation
extension LogStreamer {
    static let abstract = """
                🚂 LogStreamer V\(VERSION)
        """


    static let discussion = """
        Frontend to command log stream.
        
        Produces statistics to stdout or file
        Optionally dumps log messages to stdout or file as json.
        
        See also `man 1 log` or `log stream --help`
        """

}
