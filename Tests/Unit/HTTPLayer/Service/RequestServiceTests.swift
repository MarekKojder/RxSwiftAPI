//
//  RequestServiceTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 04.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class RequestServiceTests: XCTestCase {

    func testConstructor() {
        let service = RequestService(fileManager: DefaultFileManager())

        XCTAssertNotNil(service)
    }
}
