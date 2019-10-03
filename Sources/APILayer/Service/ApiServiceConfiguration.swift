//
//  ApiServiceConfiguration.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 05.06.2018.
//

import Foundation

public extension ApiService {

    typealias CachePolicy = NSURLRequest.CachePolicy
    typealias CookieAcceptPolicy = HTTPCookie.AcceptPolicy
    typealias CookieStorage = HTTPCookieStorage

    ///Enum containing most common behaviors and policies for requests.
    enum Configuration {
        case foreground
        case ephemeral
        case background
        case custom(URLSessionConfiguration)
    }
}

extension ApiService.Configuration {

    ///*URLSessionConfiguration* object for current session.
    var requestServiceConfiguration: RequestService.Configuration {
        switch self {
        case .foreground:
            return .foreground
        case .ephemeral:
            return .ephemeral
        case .background:
            return .background
        case .custom(let config):
            return .custom(config)
        }
    }
}

extension ApiService.Configuration: Equatable {

    public static func ==(lhs: ApiService.Configuration, rhs: ApiService.Configuration) -> Bool {
        switch (lhs, rhs) {
        case (.foreground, .foreground),
             (.ephemeral, .ephemeral),
             (.background, .background):
            return true
        case (.custom(let lhsConfig), .custom(let rhsConfig)):
            return lhsConfig == rhsConfig
        default:
            return false
        }
    }
}

public extension ApiService.Configuration {

    ///A Boolean value that determines whether connections should be made over a cellular network. The default value is true.
    var allowsCellularAccess: Bool {
        return requestServiceConfiguration.allowsCellularAccess
    }

    ///The timeout interval to use when waiting for additional data. The default value is 60.
    var timeoutForRequest: TimeInterval {
        return requestServiceConfiguration.timeoutForRequest
    }

    ///The maximum amount of time (in seconds) that a resource request should be allowed to take. The default value is 7 days.
    var timeoutForResource: TimeInterval {
        return requestServiceConfiguration.timeoutForResource
    }

    ///The maximum number of simultaneous connections to make to a given host. The default value is 6 in macOS, or 4 in iOS.
    var maximumConnectionsPerHost: Int {
        return requestServiceConfiguration.maximumConnectionsPerHost
    }

    ///A predefined constant that determines when to return a response from the cache. The default value is *.useProtocolCachePolicy*.
    var cachePolicy: ApiService.CachePolicy {
        return requestServiceConfiguration.cachePolicy
    }

    ///A Boolean value that determines whether requests should contain cookies from the cookie store. The default value is true.
    var shouldSetCookies: Bool {
        return requestServiceConfiguration.shouldSetCookies
    }

    ///A policy constant that determines when cookies should be accepted. The default value is *.onlyFromMainDocumentDomain*.
    var cookieAcceptPolicy: ApiService.CookieAcceptPolicy {
        return requestServiceConfiguration.cookieAcceptPolicy
    }

    ///The cookie store for storing cookies within this session. For *foreground* and *background* sessions, the default value is the shared cookie storage object.
    var cookieStorage: ApiService.CookieStorage? {
        return requestServiceConfiguration.cookieStorage
    }
}
