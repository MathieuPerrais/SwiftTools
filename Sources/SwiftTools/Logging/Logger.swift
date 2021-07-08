//
//  Logger.swift
//  
//
//  Created by Mathieu Perrais on 3/2/21.
//

import Foundation
import os

private let benchmarker = Benchmarker()

public enum Level: Int {
    case trace, debug, info, warning, error

    var description: String {
        return String(describing: self).uppercased()
    }
}

extension Level: Comparable {
    public static func < (lhs: Level, rhs: Level) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

open class Logger {
    /// The logger state.
    open var enabled: Bool = true

    /// The logger formatter.
    open var formatter: Formatter {
        didSet { formatter.logger = self }
    }

    /// The logger theme.
    open var theme: Theme?

    /// The minimum level of severity.
    open var minLevel: Level

    /// The logger format.
    open var format: String {
        return formatter.description
    }

    /// The logger colors
    open var colors: String {
        return theme?.description ?? ""
    }

    /// The queue used for logging.
    private let queue = DispatchQueue(label: "delba.log")

    /**
     Creates and returns a new logger.
     
     - parameter formatter: The formatter.
     - parameter theme:     The theme.
     - parameter minLevel:  The minimum level of severity.
     
     - returns: A newly created logger.
     */
    public init(formatter: Formatter = .default, theme: Theme? = nil, minLevel: Level = .trace) {
        self.formatter = formatter
        self.theme = theme
        self.minLevel = minLevel

        formatter.logger = self
    }

    /**
     Logs a message with a trace severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open func trace(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(.trace, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with a debug severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open func debug(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(.debug, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with an info severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open func info(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(.info, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with a warning severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open func warning(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(.warning, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with an error severity level.
     
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open func error(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        log(.error, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message.
     
     - parameter level:      The severity level.
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    private func log(_ level: Level, _ items: [Any], _ separator: String, _ terminator: String, _ file: String, _ line: Int, _ column: Int, _ function: String) {
        guard enabled && level >= minLevel else { return }

        let date = Date()

        let result = formatter.format(
            level: level,
            items: items,
            separator: separator,
            terminator: terminator,
            file: file,
            line: line,
            column: column,
            function: function,
            date: date
        )

        queue.async {
            Swift.print(result, separator: "", terminator: "")
        }
    }

    /**
     Measures the performance of code.
     
     - parameter description: The measure description.
     - parameter n:           The number of iterations.
     - parameter file:        The file in which the measure happens.
     - parameter line:        The line at which the measure happens.
     - parameter column:      The column at which the measure happens.
     - parameter function:    The function in which the measure happens.
     - parameter block:       The block to measure.
     */
    open func measure(_ description: String? = nil, iterations n: Int = 10, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function, block: () -> Void) {
        guard enabled && .debug >= minLevel else { return }

        let measure = benchmarker.measure(description, iterations: n, block: block)

        let date = Date()

        let result = formatter.format(
            description: measure.description,
            average: measure.average,
            relativeStandardDeviation: measure.relativeStandardDeviation,
            file: file,
            line: line,
            column: column,
            function: function,
            date: date
        )

        queue.async {
            Swift.print(result)
        }
    }
}



struct LogCategory {
    
    let name: String
    
    static let persistence = LogCategory(name: "Persistence")
    static let network = LogCategory(name: "Network")
    static let ui = LogCategory(name: "Network")
    // Notification, repository, connectivity....
    
    
}

extension LogCategory {
    static let repo = LogCategory(name: "Repo")
}

struct L {
    
    static func log(category: LogCategory, message: StaticString) {
        Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Persistence").log(message)
    }
    
    static let persistence = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Persistence")
    static let network = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Network")
    static let ui = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "UI")
    
}


let logger = Logger(subsystem: "com.mathieuperrais.test", category: "MyCategory")

let string = "Bart"

let result = logger.log("result: \(string, privacy: .public)")

struct MyLogger {
    
//    logger.
    func log<T: StringInterpolationProtocol>(log: @autoclosure () -> T) {
        os_log(log() as! StaticString)
    }
    
}
