//
//  SuccessStatusCodeType.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 16.01.2017.
//

import Foundation

public extension StatusCode {

    struct Success: StatusCodeType {

        let value: Int

        var description: String {
            switch value {
            case 200:
                return "OK"
            case 201:
                return "Created"
            case 202:
                return "Accepted"
            case 203:
                return "Non-Authoritative Information"
            case 204:
                return "No Content"
            case 205:
                return "Reset Content"
            case 206:
                return "Partial Content"
            case 207:
                return "Multi-Status"
            case 208:
                return "Already Reported"
            case 226:
                return "IM Used"
            default:
                return "Unknown status code"
            }
        }

        internal init?(_ value: Int) {
            guard value >= 200, value <= 299 else {
                return nil
            }
            self.value = value
        }
    }
}

extension StatusCode.Success: Equatable {

    public static func ==(lhs: StatusCode.Success, rhs: StatusCode.Success) -> Bool {
        return lhs.value == rhs.value
    }
}
