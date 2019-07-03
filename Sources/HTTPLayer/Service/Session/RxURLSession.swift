//
//  RxURLSession.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 03.07.2019.
//

import RxSwift
import RxCocoa

typealias RxURLSessionDelegate = URLSessionDataDelegate & URLSessionDownloadDelegate

class RxURLSession: NSObject {
    private let configuration: URLSessionConfiguration
    private var urlSession: URLSession?

    init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }

    ///Cancels all outstanding tasks and then invalidates the session.
    func invalidateAndCancel() {
        urlSession?.invalidateAndCancel()
    }

    /**
     Creates a task that retrieves the contents of a URL based on the specified URL request object.

     - Parameter request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.

     - Returns: The new session data task.

     By creating a task based on a request object, you can tune various aspects of the task’s behavior, including the cache policy and timeout interval.

     After you create the task, you must start it by calling its resume() method.
     */
    func dataTask(with request: URLRequest) -> URLSessionDataTask? {
        return urlSession?.dataTask(with: request)
    }

    /**
     Creates a task that performs an HTTP request for uploading the specified file.

     - Parameters:
     - request: A URL request object that provides the URL, cache policy, request type, and so on. The body stream and body data in this request object are ignored.
     - fileURL: The URL of the file to upload.

     - Returns: The new session upload task.

     An HTTP upload request is any request that contains a request body, such as a `POST` or `PUT` request. Upload tasks require you to create a request object so that you can provide metadata for the upload, like HTTP request headers.

     After you create the task, you must start it by calling its resume() method. The task calls methods on the session’s delegate to provide you with the upload’s progress, response metadata, response data, and so on.
     */
    func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask? {
        return urlSession?.uploadTask(with: request, fromFile: fileURL)
    }

    /**
     Creates a download task that retrieves the contents of a URL based on the specified URL request object and saves the results to a file.

     - Parameter request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.

     - Returns: The new session download task.

     By creating a task based on a request object, you can tune various aspects of the task’s behavior, including the cache policy and timeout interval.

     After you create the task, you must start it by calling its resume() method. The task calls methods on the session’s delegate to provide you with progress notifications, the location of the resulting temporary file, and so on.
     */
    func downloadTask(with request: URLRequest) -> URLSessionDownloadTask? {
        return urlSession?.downloadTask(with: request)
    }
}

private extension RxURLSession {

    func initUrlSession(with delegate: RxURLSessionDelegate) {
        guard urlSession == nil else { //URLSession already initiated
            print("URLSession delegate is read only property! Operation has no effect!")
            return
        }
        urlSession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}

extension RxURLSession: HasDelegate {
    public typealias Delegate = RxURLSessionDelegate

    var delegate: RxURLSessionDelegate? {
        get {
            return urlSession?.delegate as? RxURLSessionDelegate
        }
        set(newValue) {
            guard let delegate = newValue else {
                return
            }
            initUrlSession(with: delegate)
        }
    }
}
