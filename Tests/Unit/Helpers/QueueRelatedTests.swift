//
//  QueueRelatedTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 21/11/2019.
//

import XCTest
@testable import RxSwiftAPI

private struct TestStruct: QueueRelated {}

class QueueRelatedTests: XCTestCase {

    func testQueueName() {
        let name = "Test"
        let queue1 = TestStruct().queue(name)
        let queue2 = TestStruct().queue(name)

        XCTAssertNotEqual(queue1, queue2)
        XCTAssertTrue(queue1.contains(name))
        XCTAssertTrue(queue2.contains(name))
    }
}
