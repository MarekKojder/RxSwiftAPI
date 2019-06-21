//
//  RestServiceTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 07.02.2017.
//

import XCTest
@testable import RxSwiftAPI

class RestServiceTests: XCTestCase {

    func testConstructor() {
        let url = "https://www.google.com"
        let path = "search"
        let service = RestService(baseUrl: url, apiPath: path, headerFields: nil, coderProvider: DefaultCoderProvider(), fileManager: DefaultFileManager())

        XCTAssertEqual(service.baseUrl, url)
        XCTAssertEqual(service.apiPath, path)
        XCTAssertNotNil(service.apiService)
    }
}
