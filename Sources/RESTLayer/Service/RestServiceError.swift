//
//  RestServiceError.swift
//  SwiftAPI
//
//  Created by Marek Kojder on 04.06.2018.
//

import Foundation

public extension RestService {

    /**
     Enum for informing about RestService errors

     - url: informs about issues with creating *URL*.
     */
    enum Error: Swift.Error {
        case url
    }
}

extension RestService.Error: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .url:
            return "URL cannot be formed with given base URL, API path and resource path."
        }
    }
}
