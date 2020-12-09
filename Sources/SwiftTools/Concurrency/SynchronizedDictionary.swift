//
//  SynchronizedDictionary.swift
//  
//
//  Created by Mathieu Perrais on 12/7/20.
//

import Foundation

public class SynchronizedDictionary<Key: Hashable, Value> {
    private let queue = DispatchQueue(label: "\(DispatchQueue.labelPrefix).SynchronizedDictionary.\(UUID().uuidString)", attributes: .concurrent)
    private var dictionary = [Key:Value]()
    
    public init() { }
    
    public convenience init(_ dictionary: [Key:Value]) {
        self.init()
        self.dictionary = dictionary
    }
}

// MARK: - Inspecting a Dictionary
public extension SynchronizedDictionary {
    /// A Boolean value that indicates whether the dictionary is empty.
    var isEmpty: Bool {
        return queue.sync {
            return dictionary.isEmpty
        }
    }
    
    /// The number of key-value pairs in the dictionary.
    var count: Int {
        return queue.sync {
            return dictionary.count
        }
    }
    
    /// The total number of key-value pairs that the dictionary can contain without allocating new storage.
    var capacity: Int {
        return queue.sync {
            return dictionary.capacity
        }
    }
}

// MARK: - Accessing Keys and Values
public extension SynchronizedDictionary {
    
    /// Accesses the key-value pair at the specified position.
    subscript(key: Key, updateCompletion: (() -> Void)? = nil) -> Value? {
        get {
            return queue.sync {
                return dictionary[key]
            }
        }
        set {
            queue.async(flags: .barrier) {
                self.dictionary[key] = newValue
                DispatchQueue.main.async { updateCompletion?() }
            }
        }
    }
    
    /// Accesses the value with the given key. If the dictionary doesn’t contain the given key, accesses the provided default value as if the key and default value existed in the dictionary.
    subscript(key: Key, default defaultValue: @escaping @autoclosure () -> Value, updateCompletion: (() -> Void)? = nil) -> Value {
        get {
            return queue.sync {
                return dictionary[key, default: defaultValue()]
            }
        }
        set {
            queue.async(flags: .barrier) {
                self.dictionary[key, default: defaultValue()] = newValue
                DispatchQueue.main.async { updateCompletion?() }
            }
        }
    }
    
    /// Returns the index for the given key.
    func index(forKey key: Key) -> Dictionary<Key, Value>.Index? {
        return queue.sync {
            return dictionary.index(forKey: key)
        }
    }
    
    /// A collection containing just the keys of the dictionary.
    var keys: Dictionary<Key, Value>.Keys {
        return queue.sync {
            return dictionary.keys
        }
    }
    
    /// A collection containing just the values of the dictionary.
    var values: Dictionary<Key, Value>.Values {
        return queue.sync {
            return dictionary.values
        }
    }
    
    /// The first element of the collection.
    var first: (key: Key, value: Value)? {
        return queue.sync {
            return dictionary.first
        }
    }
    
    /// Returns a random element of the collection.
    func randomElement() -> (key: Key, value: Value)? {
        return queue.sync {
            return dictionary.randomElement()
        }
    }
    
    /// Returns a random element of the collection, using the given generator as a source for randomness.
    func randomElement<T>(using generator: inout T) -> (key: Key, value: Value)? where T : RandomNumberGenerator {
        return queue.sync {
            return dictionary.randomElement(using: &generator)
        }
    }
}


// MARK: - Adding Keys and Values
public extension SynchronizedDictionary {
    /// Updates the value stored in the dictionary for the given key, or adds a new key-value pair if the key does not exist.
    func updateValue(_ value: Value, forKey key: Key, completion: ((Value?) -> Void)? = nil) {
        return queue.async(flags: .barrier) {
            let previousValue = self.dictionary.updateValue(value, forKey: key)
            DispatchQueue.main.async { completion?(previousValue) }
        }
    }
}

// MARK: - Removing Keys and Values
public extension SynchronizedDictionary {
    /// Removes the given key and its associated value from the dictionary.
    func removeValue(forKey key: Key, completion: ((Value?) -> Void)? = nil) {
        return queue.async(flags: .barrier) {
            let value = self.dictionary.removeValue(forKey: key)
            DispatchQueue.main.async { completion?(value) }
        }
    }
    
    /// Removes and returns the key-value pair at the specified index.
    func remove(at index: Dictionary<Key, Value>.Index, completion: ((Dictionary<Key, Value>.Element) -> Void)? = nil) {
        return queue.async(flags: .barrier) {
            let value = self.dictionary.remove(at: index)
            DispatchQueue.main.async { completion?(value) }
        }
    }
    
    /// Removes all key-value pairs from the dictionary.
    func removeAll(keepingCapacity keepCapacity: Bool = false, completion: (() -> Void)? = nil) {
        return queue.async(flags: .barrier) {
            self.dictionary.removeAll(keepingCapacity: keepCapacity)
            DispatchQueue.main.async { completion?() }
        }
    }
}

// MARK: - Describing a Dictionary
public extension SynchronizedDictionary {
    
    /// A string that represents the contents of the dictionary.
    var description: String {
        queue.sync {
            return dictionary.description
        }
    }
    
    /// A string that represents the contents of the dictionary, suitable for debugging.
    var debugDescription: String {
        queue.sync {
            return dictionary.debugDescription
        }
    }
}
