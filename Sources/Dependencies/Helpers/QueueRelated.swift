//
//  QueueRelated.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 15/10/2019.
//

import Foundation

protocol QueueRelated {

    ///Type
    var dynamicType: QueueRelated.Type { get }

    ///Prefered name for the Queue
    func queue(_ name: String) -> String

    ///Prefered name for the Queue
    static func queue(_ name: String) -> String

    ///Serial Queue with prefered name.
    static func serialQueue(_ named: String) -> DispatchQueue

    ///Concurrent Queue with prefered name.
    static func concurrentQueue(_ name: String) -> DispatchQueue
}

extension QueueRelated {

    var dynamicType: QueueRelated.Type {
        return type(of: self)
    }

    func queue(_ name: String) -> String {
        return dynamicType.queue(name)
    }

    static func queue(_ name: String) -> String {
        let typeName = String(describing: self)
        let timestamp = Date().timeIntervalSince1970
        return "RxSwiftAPI.\(typeName).\(name).\(timestamp)"
    }

    static func serialQueue(_ name: String) -> DispatchQueue {
        return DispatchQueue(label: queue(name))
    }

    static func concurrentQueue(_ name: String) -> DispatchQueue {
        return DispatchQueue(label: queue(name), qos: .utility, attributes: .concurrent)
    }
}
