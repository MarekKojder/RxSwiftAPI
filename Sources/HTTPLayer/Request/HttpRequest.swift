//
//  HttpRequest.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 20.12.2016.
//

import Foundation

extension Http {

    class Request {

        ///Unique id of request.
        let uuid: UUID

        ///The URL of the receiver.
        let url: URL

        ///The HTTP request method of the receiver.
        let method: Method

        ///Array of HTTP header fields
        let headerFields: [Header]?

        /**
         Creates and initializes a HttpRequest with the given parameters.

         - Parameters:
           - url: URL of the receiver.
           - method: HTTP request method of the receiver.
           - onSuccess: action which needs to be performed when response was received from server.
           - onFailure: action which needs to be performed, when request has failed.
           - useProgress: flag indicates if Progress object should be created.

         - Returns: An initialized a HttpRequest object.
         */
        init(url: URL, method: Method, headers: [Header]? = nil) {
            self.uuid = UUID()
            self.url = url
            self.method = method
            self.headerFields = headers
        }

        ///*URLRequest* representation of current object.
        var urlRequest: URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            if let headers = headerFields {
                for header in headers {
                    request.addValue(header.value, forHTTPHeaderField: header.name)
                }
            }
            return request
        }
    }
}

extension  Http.Request: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }

    /**
     Returns a Boolean value indicating whether two requests are equal.

     - Parameters:
       - rhs: A value to compare.
       - lhs: Another value to compare.

     -Important: Two requests are equal, when their UUID's are equal, it means that function will return *true* only when you are comparing the same instance of request or copy of that instance.
     */
    public static func ==(lhs: Http.Request, rhs: Http.Request) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
