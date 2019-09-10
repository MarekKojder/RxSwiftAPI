//
//  DataExtensions.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 06/09/2019.
//

import Foundation

extension Data {

    func print() {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
            if let dataString = NSString(data: try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                                         encoding: String.Encoding.utf8.rawValue) {
                Swift.print(dataString)
            } else if let dataString = String(data: self, encoding: .utf8) {
                Swift.print(dataString)
            } else {
                Swift.print("Data could not be serialized!")
            }
        } catch {
            Swift.print("Failed to decode Data: \(error.localizedDescription)")
            if let dataString = String(data: self, encoding: .utf8) {
                Swift.print("Raw data: \(dataString)")
            }
        }
    }
}
