//
//  ConcurrencyTests.swift
//  
//
//  Created by Mathieu Perrais on 12/7/20.
//

import XCTest
@testable import SwiftTools

final class ConcurrencyTests: XCTestCase {
    
    func testAtomic() {
        let atomic = Atomic<Int>(0)
        let count = 1_000_000
        atomic.value { value in
            value = 0
        }
        
        
        DispatchQueue.concurrentPerform(iterations: count) { _ in
            atomic.value { value in
                value += 1
            }
        }
        print("count: \(count) - value: \(atomic.value)")
        XCTAssertEqual(atomic.value, count)
    }
    
    func testSynchronizedArray() {
        let array = SynchronizedArray<Int>()
        let count = 1_000_000
        DispatchQueue.concurrentPerform(iterations: count) { _ in
            if let x = array.last {
                array.append(x + array.count)
            } else {
                array.append(0)
            }
        }
        print("count: \(count) - array.count: \(array.count)")
        XCTAssert(array.count == count)
    }
    
    func testSynchronizedDictionary() {
        let dict = SynchronizedDictionary<Int, Int>()
        let count = 1_000_000
        DispatchQueue.concurrentPerform(iterations: count) { i in
            dict[i / 4] = dict[i] ?? 0
        }
        print("dict.count: \(dict.count) - count / 4: \(count / 4)")
        XCTAssert(dict.count == count / 4)
    }

    static var allTests = [
        ("testAtomic", testAtomic),
        ("testArray", testSynchronizedArray),
        ("testDictionary", testSynchronizedDictionary)
    ]
}
