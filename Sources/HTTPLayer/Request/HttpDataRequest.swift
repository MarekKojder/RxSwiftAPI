//
//  HttpDataRequest.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 02.01.2017.
//

import Foundation

extension Http {

    final class DataRequest: Request {

        ///This data is sent as the message body of the request.
        let body: Data?

        /**
         Creates and initializes a HttpDataRequest with the given parameters.

         - Parameters:
           - url: URL of the receiver.
           - method: HTTP request method of the receiver.
           - body: Data object which supposed to be a body of the request.
           - onSuccess: action which needs to be performed when response was received from server.
           - onFailure: action which needs to be performed, when request has failed.
           - useProgress: flag indicates if Progress object should be created.

         - Returns: An initialized a HttpDataRequest object.
         */
        init(url: URL, method: Method, body: Data? = nil, headers: [Header]? = nil) {
            self.body = body
            super.init(url: url, method: method, headers: headers)
        }

        override var urlRequest: URLRequest {
            var request = super.urlRequest
            request.httpBody = body
            return request
        }
    }
}
