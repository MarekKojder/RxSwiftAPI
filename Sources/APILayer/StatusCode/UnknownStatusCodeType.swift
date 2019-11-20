//
//  SuccessStatusCodeType.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 16.01.2017.
//

import Foundation

public extension StatusCode {

    struct Unknown: StatusCodeType {

        let value: Int

        var description: String {
            return "Application unknown error"
        }

        init(_ value: Int) {
            self.value = value
        }
    }
}

extension StatusCode.Unknown: Equatable {

    public static func ==(lhs: StatusCode.Unknown, rhs: StatusCode.Unknown) -> Bool {
        return lhs.value == rhs.value
    }
}
