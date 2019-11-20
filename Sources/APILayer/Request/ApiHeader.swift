//
//  ApiHeader.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 27.01.2017.
//

import Foundation

extension Api {

    public struct Header {

        ///Header field name.
        public let name: String

        ///Header field value.
        public let value: String

        /**
         - Parameters:
           - name: String containing header field name.
           - value: String containing header field value.
         */
        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }
}

extension Api.Header {

    public enum Authorization {

        private static let name = "Authorization"

        /**
         Creates authorization header.

         - Parameters:
           - value: String value of authorizaton header.

         - Returns: Ready to use Authorization header with given value.
         */
        public static func with(_ value: String) -> Api.Header {
            return Api.Header(name: name, value: value)
        }

        /**
         Creates Basic Auth header.

         - Parameters:
           - login: String which should be used as login while authorizaton.
           - password: String which should be used as password while authorizaton.

         - Returns: Ready to use Basic Auth header, or nil when credentials encoding went wrong.
         */
        public static func basic(login: String, password: String) -> Api.Header? {
            guard let credentials = "\(login):\(password)".data(using: .utf8)?.base64EncodedString(options: .init(rawValue: 0)) else {
                return nil
            }
            return Api.Header(name: name, value: "Basic \(credentials)")
        }
    }

    public enum ContentType {

        private static let name = "Content-Type"

        ///*Content-Type: text/plain* api header.
        public static var plainText: Api.Header {
            return Api.Header(name: name, value: "text/plain")
        }

        ///*Content-Type: application/json* api header.
        public static var json: Api.Header {
            return Api.Header(name: name, value: "application/json")
        }

        ///*Content-Type: application/x-www-form-urlencoded* api header.
        public static var urlEncoded: Api.Header {
            return Api.Header(name: name, value: "application/x-www-form-urlencoded")
        }

        /**
         - Parameters:
           - boundary: Custom boundary to be used in header.

         - Returns: *Content-Type: multipart/form-data* header with given boundary.
         */
        public static func multipart(with boundary: String) -> Api.Header {
            return Api.Header(name: name, value: "multipart/form-data; boundary=\(boundary)")
        }
    }
}

extension Api.Header: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
    }

    public static func ==(lhs: Api.Header, rhs: Api.Header) -> Bool {
        return lhs.name == rhs.name &&
            lhs.value == rhs.value
    }
}

extension Api.Header {

    ///Returns *HttpHeader* version of *ApiHeader*
    var httpHeader: Http.Header {
        return Http.Header(name: name, value: value)
    }
}
