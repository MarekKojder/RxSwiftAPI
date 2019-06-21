//
//  RestResponseHeader.swift
//  SwiftAPI
//
//  Created by Marek Kojder on 02.10.2018.
//

import Foundation

public struct RestResponseHeader {

    ///Header field name.
    public let name: String

    ///Header field value.
    public let value: String

    /**
     - Parameters:
       - name: String containing header field name.
       - value: String containing header field value.
     */
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}
