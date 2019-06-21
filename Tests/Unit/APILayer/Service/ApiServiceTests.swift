//
//  ApiServiceTests.swift
//  SwiftAPI
//
//  Created by Marek Kojder on 19.01.2017.
//

import XCTest
@testable import SwiftAPI2

class ApiServiceTests: XCTestCase {

    func testConstructor() {
        let service = ApiService(fileManager: DefaultFileManager())

        XCTAssertNotNil(service)
    }
}
