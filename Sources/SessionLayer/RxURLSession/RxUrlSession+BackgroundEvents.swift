//
//  RxUrlSession+BackgroundEvents.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 19/11/2019.
//

import Foundation

//MARK: URLSessionDelegate
extension RxURLSession {

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        delegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
    }
}
