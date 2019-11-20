//
//  InfoStatusCodeType.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 16.01.2017.
//

import Foundation

public extension StatusCode {

    struct Info: StatusCodeType {

        let value: Int

        var description: String {
            switch value {
            case 100:
                return "Continue"
            case 101:
                return "Switching Protocols"
            case 102:
                return "Processing"
            default:
                return "Unknown status code"
            }
        }

        internal init?(_ value: Int) {
            guard value >= 100, value <= 199 else {
                return nil
            }
            self.value = value
        }
    }
}

extension StatusCode.Info: Equatable {

    public static func ==(lhs: StatusCode.Info, rhs: StatusCode.Info) -> Bool {
        return lhs.value == rhs.value
    }
}
