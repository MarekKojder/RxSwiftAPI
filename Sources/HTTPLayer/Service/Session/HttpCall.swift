//
//  HttpCall.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 08.03.2018.
//

import Foundation

typealias SessionServiceProgressHandler = (_ totalBytesProcessed: Int64, _ totalBytesExpectedToProcess: Int64) -> ()
typealias SessionServiceCompletionHandler = (_ response: HttpResponse?, _ error: Error?) -> ()

final class HttpCall {
    
    private let progressHandler: SessionServiceProgressHandler?
    private let completionHandler: SessionServiceCompletionHandler
    private(set) var response: HttpResponse?
    private(set) var isCompleted: Bool

    init(progress: SessionServiceProgressHandler?, completion: @escaping SessionServiceCompletionHandler) {
        isCompleted = false
        progressHandler = progress
        completionHandler = completion
    }

    func update(with urlResponse: URLResponse) {
        if response == nil {
            response = HttpResponse(urlResponse: urlResponse)
        } else {
            response?.update(with: urlResponse)
        }
    }

    func update(with data: Data) {
        if response == nil {
            response = HttpResponse(body: data)
        } else {
            response?.appendBody(data)
        }
    }

    func update(with resourceUrl: URL) {
        if response == nil {
            response = HttpResponse(resourceUrl: resourceUrl)
        } else {
            response?.update(with: resourceUrl)
        }
    }

    func performProgress(totalBytesProcessed: Int64, totalBytesExpectedToProcess: Int64) {
        progressHandler?(totalBytesProcessed, totalBytesExpectedToProcess)
    }

    func performCompletion(response: HttpResponse? = nil, error: Error? = nil) {
        DispatchQueue.global(qos: .utility).async {
            self.completionHandler(response, error)
            self.isCompleted = true
        }
    }
}
