//
//  ApiServiceTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 19.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class ApiServiceTests: XCTestCase {

    func testConstructor() {
        let service = ApiService(fileManager: DefaultFileManager())

        XCTAssertNotNil(service)
    }
}
