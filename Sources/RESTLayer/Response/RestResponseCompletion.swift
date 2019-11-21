//
//  RestResponseCompletion.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 08.02.2017.
//

import Foundation

public extension Rest.Response {
    
    /**
     Closure called when api request is finished.
     - Parameters:
       - data: Decoded data returned from server if there were any.
       - error: Error which occurred while processing request or decoding response if there was any.
     */
    typealias CompletionHandler<ResponseType: Decodable> = (_ data: ResponseType?, _ details: Details) -> ()

    /**
     Closure called when api request is finished.
     - Parameters:
       - success: Flag indicates if request finished with success.
       - error: Error which occurred while processing request if there was any.
     */
    typealias SimpleCompletionHandler = (_ success: Bool, _ details: Details) -> ()
}
