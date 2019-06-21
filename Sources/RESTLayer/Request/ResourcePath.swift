//
//  ResourcePath.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 30.01.2018.
//

/// A type that can be used as a path of the resource.
public protocol ResourcePath {

    ///The string to use as path of the resource.
    var rawValue: String { get }
}
