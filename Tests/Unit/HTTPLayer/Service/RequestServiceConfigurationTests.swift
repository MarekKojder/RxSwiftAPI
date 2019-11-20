//
//  RequestServiceConfigurationTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 19.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class RequestServiceConfigurationTests: XCTestCase {
    
    func testForegroundConfiguration() {
        let config = Http.Service.Configuration.foreground
        let sessionConfig = config.urlSessionConfiguration

        XCTAssertNil(sessionConfig.identifier)
        XCTAssertNotEqual(config, Http.Service.Configuration.background("SomeTestId"))
        XCTAssertNotEqual(config, Http.Service.Configuration.ephemeral)
    }

    func testEphemeralConfiguration() {
        let config = Http.Service.Configuration.ephemeral
        let sessionConfig = config.urlSessionConfiguration

        XCTAssertNil(sessionConfig.identifier)
        XCTAssertNotEqual(config, Http.Service.Configuration.background("SomeTestId"))
        XCTAssertNotEqual(config, Http.Service.Configuration.foreground)
    }
    
    func testBackgroundConfiguration() {
        let config = Http.Service.Configuration.background("SomeTestId")
        let sessionConfig = config.urlSessionConfiguration

        XCTAssertNotNil(sessionConfig.identifier)
        XCTAssertNotEqual(config, Http.Service.Configuration.foreground)
        XCTAssertNotEqual(config, Http.Service.Configuration.ephemeral)
    }

    func testCustomConfiguration() {
        let sessionConfiguration = URLSessionConfiguration.default
        let config = Http.Service.Configuration.custom(sessionConfiguration)
        let sessionConfig = config.urlSessionConfiguration

        XCTAssertEqual(sessionConfiguration, sessionConfig)
        XCTAssertNotEqual(config, Http.Service.Configuration.foreground)
        XCTAssertNotEqual(config, Http.Service.Configuration.ephemeral)
        XCTAssertNotEqual(config, Http.Service.Configuration.background("SomeTestId"))
    }

    func testAllowsCellularAccess() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.allowsCellularAccess = false
        let config = Http.Service.Configuration.custom(sessionConfiguration)

        XCTAssertEqual(sessionConfiguration.allowsCellularAccess, config.allowsCellularAccess)
    }

    func testTimeoutForRequest() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 9999
        let config = Http.Service.Configuration.custom(sessionConfiguration)

        XCTAssertEqual(sessionConfiguration.timeoutIntervalForRequest, config.timeoutForRequest)
    }

    func testTimeoutForResource() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForResource = 7777
        let config = Http.Service.Configuration.custom(sessionConfiguration)

        XCTAssertEqual(sessionConfiguration.timeoutIntervalForResource, config.timeoutForResource)
    }

    func testMaximumConnectionsPerHost() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpMaximumConnectionsPerHost = 1234
        let config = Http.Service.Configuration.custom(sessionConfiguration)

        XCTAssertEqual(sessionConfiguration.httpMaximumConnectionsPerHost, config.maximumConnectionsPerHost)
    }

    func testCachePolicy() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let config = Http.Service.Configuration.custom(sessionConfiguration)

        XCTAssertEqual(sessionConfiguration.requestCachePolicy, config.cachePolicy)
    }

    func testShouldSetCookies() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpShouldSetCookies = false
        let config = Http.Service.Configuration.custom(sessionConfiguration)

        XCTAssertEqual(sessionConfiguration.httpShouldSetCookies, config.shouldSetCookies)
    }

    func testCookieAcceptPolicy() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpCookieAcceptPolicy = .onlyFromMainDocumentDomain
        let config = Http.Service.Configuration.custom(sessionConfiguration)

        XCTAssertEqual(sessionConfiguration.httpCookieAcceptPolicy, config.cookieAcceptPolicy)
    }

    func testCookieStorage() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpCookieStorage = HTTPCookieStorage.shared
        let config = Http.Service.Configuration.custom(sessionConfiguration)

        XCTAssertEqual(sessionConfiguration.httpCookieStorage, config.cookieStorage)
    }
}
