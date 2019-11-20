//
//  HttpMethod.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 16.12.2016.
//

import Foundation

extension Http {
    
    /**
     HTTP methods for RESTful services.

     - get: use it to read data but not change it,
     - post: use it to create new resource,
     - put: use it to update/replace data at known resource URI
     - patch: use it to update data, but request only needs to contain the changes to the resource, not the complete resource.
     - delete: to delete a resource identified by a URI.
     */
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
}

extension Http.Method: Equatable {
    
    public static func ==(lhs: Http.Method, rhs: Http.Method) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
