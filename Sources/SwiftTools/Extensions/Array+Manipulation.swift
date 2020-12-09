//
//  Array+Manipulation.swift
//  
//
//  Created by Mathieu Perrais on 12/7/20.
//

import Foundation

public extension Array {
    init(withCapacity capacity: Int) {
        self.init()
        reserveCapacity(capacity)
    }
    
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
}

public extension Array where Element: Equatable {
    /// New Array with all duplicates removed from it.
    ///
    ///     [1, 3, 3, 5, 7, 9].distinct // [1, 3, 5, 7, 9]
    var distinct: [Element] {
        // https://github.com/SwifterSwift/SwifterSwift
        return reduce(into: [Element]()) {
            guard !$0.contains($1) else { return }
            $0.append($1)
        }
    }

    /// Remove all duplicates (in place)
    ///
    ///     var array = [1, 3, 3, 5, 7, 9]
    ///     array.removeDuplicates()
    ///     array // [1, 3, 5, 7, 9]
    mutating func removeDuplicates() {
        self = distinct
    }
}
