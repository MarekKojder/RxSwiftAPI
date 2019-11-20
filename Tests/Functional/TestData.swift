//
//  TestData.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 21.06.2019.
//

import XCTest
@testable import RxSwiftAPI

enum TestData {

    enum Path {

        static var root: String {
            return "https://httpbin.org/"
        }

        static var downloadRoot: String {
            return "https://upload.wikimedia.org/"
        }
    }

    enum Url {

        private class TestClass: XCTestCase {}

        static var root: URL {
            return URL(string: Path.root)!
        }

        static var documents: URL {
            return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true)
        }

        static var localFile: URL {
            return Bundle(for: TestClass.self).url(forResource: "testImage", withExtension: "jpg")!
        }

        static var smallFile: URL {
            return URL(string: "https://upload.wikimedia.org/wikipedia/commons/d/d1/Mount_Everest_as_seen_from_Drukair2_PLW_edit.jpg")!
        }

        static var bigFile: URL {
            return URL(string: "https://upload.wikimedia.org/wikipedia/commons/3/3f/Fronalpstock_big.jpg")!
        }
    }

    enum Headers {

        static var example: [Api.Header] {
            return [Api.Header(name: "User-Agent", value: "RxSwiftAPI")]
        }

        static var auth: [Api.Header] {
            return [Api.Header.Authorization.basic(login: "admin", password: "admin1")!]
        }
    }
}
