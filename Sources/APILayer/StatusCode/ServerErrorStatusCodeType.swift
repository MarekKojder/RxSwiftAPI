//
//  SuccessStatusCodeType.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 16.01.2017.
//

import Foundation

public extension StatusCode {
    
    struct ServerError: StatusCodeType {
        
        let value: Int
        
        var description: String {
            switch value {
            case 500:
                return "Internal Server Error"
            case 501:
                return "Not Implemented"
            case 502:
                return "Bad Gateway"
            case 503:
                return "Service Unavailable"
            case 504:
                return "Gateway Timeout"
            case 505:
                return "HTTP Version Not Supported"
            case 506:
                return "Variant Also Negotiates"
            case 507:
                return "Insufficient Storage"
            case 508:
                return "Loop Detected"
            case 510:
                return "Not Extended"
            case 511:
                return "Network Authentication Required"
            default:
                return "Unknown status code"
            }
        }
        
        internal init?(_ value: Int) {
            guard value >= 500, value <= 599 else {
                return nil
            }
            self.value = value
        }
    }
}

extension StatusCode.ServerError: Equatable {
    
    public static func ==(lhs: StatusCode.ServerError, rhs: StatusCode.ServerError) -> Bool {
        return lhs.value == rhs.value
    }
}
