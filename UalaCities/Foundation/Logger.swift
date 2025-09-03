//
//  Logger.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import Foundation

class Logger {
    // It can be a protocol but protocol doesn't support ensted types
    // e.g. I prefer Logger.Level instead of LoggerLevel
    
    enum Level {
        case debug, info, warning, error, fatal
    }
    struct Entry {
        var level: Level
        var message: String
        var fileId: String
        var function: String
        var file: StaticString
        var line: UInt
    }
    
    final func log(_ level: Level, _ message: String, fileId: String = #fileID, function: String = #function, file: StaticString = #file, line: UInt = #line) {
        log(.init(level: level, message: message, fileId: fileId, function: function, file: file, line: line))
    }
    
    func log(_ entry: Entry) {}
}

class NoLogger: Logger {
    override func log(_ entry: Entry) {}
}

class ConsoleLogger: Logger {
    override func log(_ entry: Logger.Entry) {
        print("\(entry.level): \(entry.message)")
    }
}

class SpiedLogger: Logger {
    private(set) var entries: [Entry] = []
    override func log(_ entry: Logger.Entry) {
        entries.append(entry)
    }
}
