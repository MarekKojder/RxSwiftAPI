//
//  RxURLSession.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 03.07.2019.
//

import RxSwift
import RxCocoa

public typealias RxURLSessionDelegate = URLSessionDataDelegate & URLSessionDownloadDelegate

/**
 Class introduces URLSessionDelegate with read and write access and forces implementation of URLSessionDataDelegate and URLSessionDownloadDelegate protocols.

 Read and write access to delegate is required by *DelegateProxyType* protocol which is required for creating delegate proxy to RxSwift.
 */
open class RxURLSession: NSObject {
    let configuration: URLSessionConfiguration
    private lazy var urlSession: URLSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

    public weak var delegate: RxURLSessionDelegate?

    public init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
        super.init()
    }
}

//MARK: Forwarding URLSession methods
public extension RxURLSession {

    /**
     Creates a task that retrieves the contents of a URL based on the specified URL request object.

     - Parameter request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.

     - Returns: The new session data task.

     By creating a task based on a request object, you can tune various aspects of the task’s behavior, including the cache policy and timeout interval.

     After you create the task, you must start it by calling its resume() method.
     */
    func dataTask(with request: URLRequest) -> URLSessionDataTask {
        return urlSession.dataTask(with: request)
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
    func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        return urlSession.uploadTask(with: request, fromFile: fileURL)
    }

    /**
     Creates a download task that retrieves the contents of a URL based on the specified URL request object and saves the results to a file.

     - Parameter request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.

     - Returns: The new session download task.

     By creating a task based on a request object, you can tune various aspects of the task’s behavior, including the cache policy and timeout interval.

     After you create the task, you must start it by calling its resume() method. The task calls methods on the session’s delegate to provide you with progress notifications, the location of the resulting temporary file, and so on.
     */
    func downloadTask(with request: URLRequest) -> URLSessionDownloadTask {
        return urlSession.downloadTask(with: request)
    }

    /**
     Cancels all outstanding tasks and then invalidates the session.

     Once invalidated, references to the delegate and callback objects are broken. After invalidation, session objects cannot be reused.

     To allow outstanding tasks to run until completion, call finishTasksAndInvalidate() instead.
     */
    func invalidateAndCancel() {
        urlSession.invalidateAndCancel()
    }

    /**
     Invalidates the session, allowing any outstanding tasks to finish.

     This method returns immediately without waiting for tasks to finish. Once a session is invalidated, new tasks cannot be created in the session, but existing tasks continue until completion. After the last task finishes and the session makes the last delegate call related to those tasks, the session calls the urlSession(_:didBecomeInvalidWithError:) method on its delegate, then breaks references to the delegate and callback objects. After invalidation, session objects cannot be reused.

     To cancel all outstanding tasks, call invalidateAndCancel() instead.
     */
    func finishTasksAndInvalidate() {
        urlSession.finishTasksAndInvalidate()
    }
}

//MARK: HasDelegate Protocol
extension RxURLSession: HasDelegate {
    
    public typealias Delegate = RxURLSessionDelegate
}

//MARK: URLSessionDelegate
extension RxURLSession: URLSessionDelegate {

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        delegate?.urlSession?(session, didBecomeInvalidWithError: error)
    }
}

//MARK: URLSessionTaskDelegate Protocol
extension RxURLSession: URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        delegate?.urlSession?(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.urlSession?(session, task: task, didCompleteWithError: error)
    }
}

//MARK: URLSessionDataDelegate Protocol
extension RxURLSession: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        delegate?.urlSession?(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        delegate?.urlSession?(session, dataTask: dataTask, didReceive: data)
    }
}

//MARK: URLSessionDownloadDelegate Protocol
extension RxURLSession: URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        delegate?.urlSession?(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}
