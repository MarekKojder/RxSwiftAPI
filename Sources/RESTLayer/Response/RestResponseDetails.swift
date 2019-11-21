//
//  RestResponseDetails.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 02.10.2018.
//

import Foundation

public extension Rest.Response {

    struct Details {

        ///Error object containing internal errors.
        public internal(set) var error: Error?

        ///The status code of the receiver.
        public let statusCode: StatusCode

        ///Data object returned by receiver.
        public let rawBody: Data?

        ///A dictionary containing all the HTTP header fields of the receiver.
        public let responseHeaderFields: [Header]

        init(_ error: Error?) {
             self.error = error
             statusCode = StatusCode.internalError
             rawBody = nil
             responseHeaderFields = []
         }

        init(_ response: Api.Response) {
             error = nil
             statusCode = response.statusCode
             rawBody = response.body
             responseHeaderFields = response.allHeaderFields?.map { Header(name: $0.0, value: $0.1) } ?? []
         }

         ///Prints to console pretty formatted JSON docoded from body.
         public func printPrettyBody() {
             guard let body = rawBody else {
                 print("Body is nil.")
                 return
             }
             body.print()
         }
     }
}
