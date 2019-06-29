//
//  RxURLSessionDelegateProxy.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 28.06.2019.
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

class RxURLSessionDelegateProxy: DelegateProxy<RxURLSession, RxURLSessionDelegate> {

    private(set) weak var urlSession: RxURLSession?

    init(urlSession: ParentObject) {
        self.urlSession = urlSession
        super.init(parentObject: urlSession, delegateProxy: RxURLSessionDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        register { RxURLSessionDelegateProxy(urlSession: $0) }
    }
}

extension RxURLSessionDelegateProxy: DelegateProxyType {}

extension RxURLSessionDelegateProxy: RxURLSessionDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        urlSession?.delegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }
}

extension Reactive where Base: RxURLSession {

    var delegate: DelegateProxy<RxURLSession, RxURLSessionDelegate> {
        return RxURLSessionDelegateProxy.proxy(for: base)
    }

    //MARK: URLSessionDelegate
    var didBecomeInvalidWithError: Observable<(session: URLSession, error: Error?)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:didBecomeInvalidWithError:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as? Error)
        }
    }

    //MARK: URLSessionTaskDelegate
    var didSendBodyData: Observable<(session: URLSession, task: URLSessionTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionTask,
                    parameters[2] as! Int64,
                    parameters[3] as! Int64,
                    parameters[4] as! Int64)
        }
    }

    var didCompleteWithError: Observable<(session: URLSession, task: URLSessionTask, error: Error?)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:task:didCompleteWithError:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionTask,
                    parameters[2] as? Error)
        }
    }

    //MARK: URLSessionDataDelegate
    var didReceiveResponse: Observable<(session: URLSession, task: URLSessionDataTask, response: URLResponse, completion: (URLSession.ResponseDisposition) -> Void)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:dataTask:didReceive:completionHandler:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionDataTask,
                    parameters[2] as! URLResponse,
                    parameters[3] as! (URLSession.ResponseDisposition) -> Void)
        }
    }

    var didReceiveData: Observable<(session: URLSession, task: URLSessionDataTask, response: Data)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:dataTask:didReceive:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionDataTask,
                    parameters[2] as! Data)
        }
    }

    //MARK: URLSessionDownloadDelegate
    var didFinishDownloading: Observable<(session: URLSession, task: URLSessionDownloadTask, location: URL)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:downloadTask:didFinishDownloadingTo:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionDownloadTask,
                    parameters[2] as! URL)
        }
    }

    var didWriteData: Observable<(session: URLSession, task: URLSessionDownloadTask, bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionDownloadTask,
                    parameters[2] as! Int64,
                    parameters[3] as! Int64,
                    parameters[4] as! Int64)
        }
    }
}
