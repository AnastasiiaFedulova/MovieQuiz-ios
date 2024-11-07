//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Anastasiia on 01.11.2024.
//

import Foundation
import XCTest

class ArrayTests: XCTestCase {
    
    func testGetValueInRange() throws {
        
        let array = [1, 1, 2, 3, 5]
        
        let value = array[2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        
        let array = [1, 1, 2, 3, 5]
        
        let value = array[20]
        
        XCTAssertNil(value)
    }
}
