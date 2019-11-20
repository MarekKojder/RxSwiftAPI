//
//  HttpHeader.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 23.01.2017.
//

import Foundation

extension Http {

    /**
     Struct containing HTTP header data. Header allows the client and the server to pass additional information with the request or the response.
     */
    struct Header {

        ///HTTP header field name.
        let name: String

        ///HTTP header field value.
        let value: String

        /**
         - Parameters:
         - name: String containing HTTP header field name.
         - value: String containing HTTP header field value.
         */
        init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }
}

extension Http.Header: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
    }

    public static func ==(lhs: Http.Header, rhs: Http.Header) -> Bool {
        return lhs.name == rhs.name &&
               lhs.value == rhs.value
    }
}
