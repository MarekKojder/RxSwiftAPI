//
//  OSXTestData.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 21.06.2019.
//

import Foundation

extension TestData.Url {
    
    static var fileDestination: URL {
        return documents.appendingPathComponent("image1.png")
    }

    static var anotherFileDestination: URL {
        return documents.appendingPathComponent("image2.png")
    }
}
