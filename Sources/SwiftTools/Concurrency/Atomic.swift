//
//  Atomic.swift
//  
//
//  Created by Mathieu Perrais on 12/6/20.
//

import Foundation

/// A wrapper object that allows read and write (with block) in an Atomic and Thread-safe manner.
public class Atomic<Value> {
    private let mutex = DispatchQueue(label: "\(DispatchQueue.labelPrefix).Atomic.\(UUID().uuidString)", attributes: .concurrent)
    private var _value: Value

    public init(_ value: Value) {
        self._value = value
    }

    /// Returns the thread-safe value.
    public var value: Value { mutex.sync { _value } }

    /// Submits a block for synchronous and thread-safe execution.
    public func value<T>(execute task: (inout Value) -> T) -> T {
        mutex.sync(flags: .barrier) { task(&_value) }
    }
}

extension Atomic : CustomStringConvertible where Value : CustomStringConvertible {
    public var description: String {
        return value.description
    }
}

extension Atomic : CustomDebugStringConvertible where Value : CustomDebugStringConvertible {
    public var debugDescription: String {
        return value.debugDescription
    }
}
