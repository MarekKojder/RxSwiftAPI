//
//  ApiError.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 17.01.2017.
//

import Foundation

extension Api {

    struct Error {

        ///Domain of RxSwiftAPI errors.
        private static let apiDomain = "RxSwiftAPIServiceErrorDomain"

        ///Creates NSError with given code and description.
        private static func errorWith(code: Int, description: String) -> Swift.Error {
            return NSError(domain: apiDomain, code: code, userInfo: [NSLocalizedDescriptionKey : description])
        }

        ///Error called when service did not received response.
        static var noResponse: Swift.Error {
            return errorWith(code: -10, description: "Rest service did not receive response.")
        }

        ///Error called when service did not received response.
        static var unknownError: Swift.Error {
            return errorWith(code: -11, description: "Unknown error.")
        }

        /**
         Creates Error representation of not success status code.

         - Parameter statusCode: StatusCode for which should be created Error.
         */
        static func error(for statusCode: StatusCode?) -> Swift.Error? {
            guard let statusCode = statusCode, !statusCode.isSuccess else {
                return nil
            }
            return errorWith(code: statusCode.rawValue * 10, description: statusCode.description)
        }
    }
}
