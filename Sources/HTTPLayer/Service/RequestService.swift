//
//  APIRequest.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 16.12.2016.
//

import Foundation

final class RequestService: NSObject {

    typealias CompletionHandler = SessionService.CompletionHandler

    private let fileManager: FileManager

    //MARK: - Handling multiple sessions
    private var sessions = [SessionService]()

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
        invalidateAndCancel()
    }
}

//MARK: - Managing requests
extension RequestService {

    /**
     Sends given HTTP request.

     - Parameters:
       - request: An HttpDataRequest object provides request-specific information such as the URL, HTTP method or body data.
       - configuration: RequestService.Configuration indicates request configuration.
       - completion: Block for hangling request completion.

     - Returns: Task object which allows to follow progress and manage request.

     - Throws: Error when Task could not be created.

     HttpDataRequest may run only with foreground configuration.
     */
    func sendHTTP(request: HttpDataRequest, with configuration: Configuration, completion: @escaping CompletionHandler) throws -> SessionService.Task {
        let session = activeSession(for: configuration)
        return try session.data(request: request.urlRequest, completion: completion)
    }

    /**
     Sends given HTTP request.

     - Parameters:
       - request: An HttpUploadRequest object provides request-specific information such as the URL, HTTP method or URL of the file to upload.
       - configuration: RequestService.Configuration indicates upload request configuration.
       - completion: Block for hangling request completion.

     - Returns: Task object which allows to follow progress and manage request.

     - Throws: Error when Task could not be created.
     */
    func sendHTTP(request: HttpUploadRequest, with configuration: Configuration, completion: @escaping CompletionHandler) throws -> SessionService.Task {
        let session = activeSession(for: configuration)
        return try session.upload(request: request.urlRequest, file: request.resourceUrl, completion: completion)
    }

    /**
     Sends given HTTP request.

     - Parameters:
       - request: An HttpUploadRequest object provides request-specific information such as the URL, HTTP method or URL of the place on disc for downloading file.
       - configuration: RequestService.Configuration indicates download request configuration.
       - completion: Block for hangling request completion.

     - Returns: Task object which allows to follow progress and manage request.

     - Throws: Error when Task could not be created.
     */
    func sendHTTP(request: HttpDownloadRequest, with configuration: Configuration, completion: @escaping CompletionHandler) throws -> SessionService.Task {
        let session = activeSession(for: configuration)
        return try session.download(request: request.urlRequest, completion: completion)
    }

    ///Cancels all currently running HTTP requests.
    func cancelAllRequests() {
        sessions.forEach { $0.cancelAllRequests() }
    }

    ///Cancels all currently running HTTP requests.
    func invalidateAndCancel() {
        sessions.forEach { $0.invalidateAndCancel() }
        sessions.removeAll()
    }
}
