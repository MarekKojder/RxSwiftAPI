//
//  ApiServiceConfigurationTests.swift
//  UnitTests iOS
//
//  Created by Marek Kojder on 05.06.2018.
//

import XCTest
@testable import RxSwiftAPI

class ApiServiceConfigurationTests: XCTestCase {

    func testForegroundConfiguration() {
        let config1 = ApiService.Configuration.foreground
        let config2 = ApiService.Configuration.foreground
        let config3 = RequestService.Configuration.foreground

        XCTAssertEqual(config1, config2)
        XCTAssertEqual(config2.requestServiceConfiguration, config3)
        XCTAssertNotEqual(config1, ApiService.Configuration.background)
        XCTAssertNotEqual(config1, ApiService.Configuration.ephemeral)
    }

    func testSettingForegroundConfiguration() {
        checkAndChangeParameters(for: .foreground)
    }

    func testBackgroundConfiguration() {
        let config1 = ApiService.Configuration.background
        let config2 = ApiService.Configuration.background
        let config3 = RequestService.Configuration.background

        XCTAssertEqual(config1, config2)
        XCTAssertEqual(config2.requestServiceConfiguration, config3)
        XCTAssertNotEqual(config1, ApiService.Configuration.foreground)
        XCTAssertNotEqual(config1, ApiService.Configuration.ephemeral)
    }

    func testSettingBackgroundConfiguration() {
        checkAndChangeParameters(for: .background)
    }

    func testEphemeralConfiguration() {
        let config1 = ApiService.Configuration.ephemeral
        let config2 = ApiService.Configuration.ephemeral
        let config3 = RequestService.Configuration.ephemeral

        XCTAssertEqual(config1, config2)
        XCTAssertEqual(config2.requestServiceConfiguration, config3)
        XCTAssertEqual(config2.shouldSetCookies, config3.shouldSetCookies)
        XCTAssertEqual(config2.cookieAcceptPolicy, config3.cookieAcceptPolicy)
        XCTAssertEqual(config2.cachePolicy, config3.cachePolicy)
        XCTAssertNotEqual(config1, ApiService.Configuration.foreground)
        XCTAssertNotEqual(config1, ApiService.Configuration.background)
    }

    func testCustomConfiguration() {
        let sessionConfiguration = URLSessionConfiguration()
        let config1 = ApiService.Configuration.custom(sessionConfiguration)
        let config2 = ApiService.Configuration.custom(sessionConfiguration)
        let config3 = RequestService.Configuration.custom(sessionConfiguration)

        XCTAssertEqual(config1, config2)
        XCTAssertEqual(config2.requestServiceConfiguration, config3)
        XCTAssertNotEqual(config1, ApiService.Configuration.foreground)
        XCTAssertNotEqual(config1, ApiService.Configuration.ephemeral)
        XCTAssertNotEqual(config1, ApiService.Configuration.background)
    }

    func testSettingCustomConfiguration() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.allowsCellularAccess = true
        sessionConfiguration.timeoutIntervalForRequest = 1
        sessionConfiguration.timeoutIntervalForResource = 2
        sessionConfiguration.httpMaximumConnectionsPerHost = 10
        sessionConfiguration.requestCachePolicy = .returnCacheDataDontLoad
        sessionConfiguration.httpShouldSetCookies = true
        sessionConfiguration.httpCookieAcceptPolicy = .never
        sessionConfiguration.httpCookieStorage = HTTPCookieStorage.shared
        let config = ApiService.Configuration.custom(sessionConfiguration)

        checkAndChangeParameters(for: config)
    }
}

private extension ApiServiceConfigurationTests {

    func checkAndChangeParameters(for apiConfig: ApiService.Configuration, file: StaticString = #file, line: UInt = #line) {
        let requestConfig = apiConfig.requestServiceConfiguration

        XCTAssertEqual(apiConfig.allowsCellularAccess, requestConfig.allowsCellularAccess, file: file, line: line)
        XCTAssertEqual(apiConfig.timeoutForRequest, requestConfig.timeoutForRequest, file: file, line: line)
        XCTAssertEqual(apiConfig.timeoutForResource, requestConfig.timeoutForResource, file: file, line: line)
        XCTAssertEqual(apiConfig.maximumConnectionsPerHost, requestConfig.maximumConnectionsPerHost, file: file, line: line)
        XCTAssertEqual(apiConfig.cachePolicy, requestConfig.cachePolicy, file: file, line: line)
        XCTAssertEqual(apiConfig.shouldSetCookies, requestConfig.shouldSetCookies, file: file, line: line)
        XCTAssertEqual(apiConfig.cookieAcceptPolicy, requestConfig.cookieAcceptPolicy, file: file, line: line)
        XCTAssertEqual(apiConfig.cookieStorage, requestConfig.cookieStorage, file: file, line: line)
    }
}
