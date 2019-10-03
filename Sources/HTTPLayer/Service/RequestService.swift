//
//  APIRequest.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 16.12.2016.
//

import Foundation
import RxSwift

typealias HttpRequestCompletionHandler = SessionServiceCompletionHandler

final class RequestService: NSObject {

    private let fileManager: FileManager

    //MARK: - Handling multiple sessions
    private var sessions = [SessionService]()
    private let disposeBag = DisposeBag()

    ///Returns URLSession for given configuration. If session does not exist, it creates one.
    private func activeSession(for configuration: Configuration) -> SessionService {
        if let session = sessions.first(where: { $0.configuration == configuration }), session.status == .valid {
            return session
        }
        sessions.removeAll(where: { $0.status == .invalidated })
        let service = SessionService(configuration: configuration)
        sessions.append(service)
        return service
    }

    //MARK: - Handling background sessions
    ///Keeps completion handler for background sessions.
    lazy var backgroundSessionCompletionHandler = [String : () -> Void]()

    //MARK: Initialization
    ///Initializes service with given file manager.
    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    deinit {
        sessions.forEach { $0.invalidateAndCancel() }
    }
}

//MARK: - Managing requests
extension RequestService {

    /**
     Sends given HTTP request.

     - Parameters:
       - request: An HttpDataRequest object provides request-specific information such as the URL, HTTP method or body data.
       - configuration: RequestService.Configuration indicates request configuration.

     HttpDataRequest may run only with foreground configuration.
     */
    func sendHTTPRequest(_ request: HttpDataRequest, with configuration: Configuration = .foreground, progress: SessionServiceProgressHandler?, completion: @escaping HttpRequestCompletionHandler) {
        let session = activeSession(for: configuration)
        session.data(request: request.urlRequest, progress: progress, completion: completion)
    }

    /**
     Sends given HTTP request.

     - Parameters:
       - request: An HttpUploadRequest object provides request-specific information such as the URL, HTTP method or URL of the file to upload.
       - configuration: RequestService.Configuration indicates upload request configuration.
     */
    func sendHTTPRequest(_ request: HttpUploadRequest, with configuration: Configuration = .background, progress: SessionServiceProgressHandler?, completion: @escaping HttpRequestCompletionHandler) {
        let session = activeSession(for: configuration)
        session.upload(request: request.urlRequest, file: request.resourceUrl, progress: progress, completion: completion)
    }

    /**
     Sends given HTTP request.

     - Parameters:
       - request: An HttpUploadRequest object provides request-specific information such as the URL, HTTP method or URL of the place on disc for downloading file.
       - configuration: RequestService.Configuration indicates download request configuration.
     */
    func sendHTTPRequest(_ request: HttpDownloadRequest, with configuration: Configuration = .background, progress: SessionServiceProgressHandler?, completion: @escaping HttpRequestCompletionHandler) {
        let session = activeSession(for: configuration)
        session.download(request: request.urlRequest, progress: progress, completion: completion)
    }

    /**
     Temporarily suspends given HTTP request.

     - Parameter request: An HttpRequest to suspend.
     */
    func suspend(_ request: HttpRequest) {
        sessions.forEach { $0.suspend(request.urlRequest) }
    }

    /**
     Resumes given HTTP request, if it is suspended.

     - Parameter request: An HttpRequest to resume.
     */
    @available(iOS 9.0, OSX 10.11, *)
    func resume(_ request: HttpRequest) {
        sessions.forEach { $0.resume(request.urlRequest) }
    }

    /**
     Cancels given HTTP request.

     - Parameter request: An HttpRequest to cancel.
     */
    func cancel(_ request: HttpRequest) {
        sessions.forEach { $0.cancel(request.urlRequest) }
    }

    ///Cancels all currently running HTTP requests.
    func cancelAllRequests() {
        sessions.forEach { $0.cancelAllRequests() }
    }
}
