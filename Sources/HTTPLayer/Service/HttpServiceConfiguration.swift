//
//  WebserviceSession.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 02.01.2017.
//

import Foundation

extension Http.Service {

    ///Available session configurations using while sending requests.
    enum Configuration {
        case foreground
        case ephemeral
        case background(String)
        case custom(URLSessionConfiguration)
    }
}

extension Http.Service.Configuration {

    ///*URLSessionConfiguration* object for current session.
    var urlSessionConfiguration: URLSessionConfiguration {
        switch self {
        case .foreground:
            return .default
        case .ephemeral:
            return .ephemeral
        case .background(let id):
            return .background(withIdentifier: id)
        case .custom(let config):
            return config
        }
    }
}

extension Http.Service.Configuration: Equatable {

    public static func ==(lhs: Http.Service.Configuration, rhs: Http.Service.Configuration) -> Bool {
        switch (lhs, rhs) {
        case (.foreground, .foreground),
             (.ephemeral, .ephemeral):
            return true
        case (.background(let lhsId), .background(let rhsId)):
            return lhsId == rhsId
        case (.custom(let lhsConfig), .custom(let rhsConfig)):
            return lhsConfig == rhsConfig
        default:
            return false
        }
    }
}

extension Http.Service.Configuration {

    ///A Boolean value that determines whether connections should be made over a cellular network. The default value is true.
    var allowsCellularAccess: Bool {
        return urlSessionConfiguration.allowsCellularAccess
    }

    ///The timeout interval to use when waiting for additional data. The default value is 60.
    var timeoutForRequest: TimeInterval {
        return urlSessionConfiguration.timeoutIntervalForRequest
    }

    ///The maximum amount of time (in seconds) that a resource request should be allowed to take. The default value is 7 days.
    var timeoutForResource: TimeInterval {
        return urlSessionConfiguration.timeoutIntervalForResource
    }

    ///The maximum number of simultaneous connections to make to a given host. The default value is 6 in macOS, or 4 in iOS.
    var maximumConnectionsPerHost: Int {
        return urlSessionConfiguration.httpMaximumConnectionsPerHost
    }

    ///A predefined constant that determines when to return a response from the cache. The default value is *.useProtocolCachePolicy*.
    var cachePolicy: NSURLRequest.CachePolicy {
        return urlSessionConfiguration.requestCachePolicy
    }

    ///A Boolean value that determines whether requests should contain cookies from the cookie store. The default value is true.
    var shouldSetCookies: Bool {
        return urlSessionConfiguration.httpShouldSetCookies
    }

    ///A policy constant that determines when cookies should be accepted. The default value is *.onlyFromMainDocumentDomain*.
    var cookieAcceptPolicy: HTTPCookie.AcceptPolicy {
        return urlSessionConfiguration.httpCookieAcceptPolicy
    }

    ///The cookie store for storing cookies within this session. For *foreground* and *background* sessions, the default value is the shared cookie storage object.
    var cookieStorage: HTTPCookieStorage? {
        return urlSessionConfiguration.httpCookieStorage
    }
}
