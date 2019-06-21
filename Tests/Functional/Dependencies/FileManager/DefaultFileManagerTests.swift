//
//  DefaultFileManagerTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 19.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class DefaultFileManagerTests: XCTestCase {

    func testCoppyFileWithSuccess() {
        let manager = DefaultFileManager()
        let source = TestData.Url.localFile
        let destination = TestData.Url.fileDestination

        let error = manager.copyFile(from: source, to: destination)

        XCTAssertNil(error)
    }
    
    func testCoppyFileWithError() {
        let manager = DefaultFileManager()
        let destination = TestData.Url.fileDestination

        let error = manager.copyFile(from: destination, to: destination)

        XCTAssertNotNil(error)
    }
    
}
