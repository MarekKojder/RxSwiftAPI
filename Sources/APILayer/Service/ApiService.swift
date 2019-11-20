//
//  ApiService.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 13.01.2017.
//

import RxSwift
import RxCocoa

extension Api {

    final public class Service {

        public typealias CompletionHandler = (_ response: Api.Response?, _ error: Swift.Error?) -> ()

        ///Service managing requests
        let requestService: Http.Service

        /**
         - Parameter fileManager: Object of class implementing *FileManager* protocol.
         */
        public init(fileManager: FileManager = DefaultFileManager()) {
            self.requestService = Http.Service(fileManager: fileManager)
        }

        ///Cancels all currently running requests.
        public func cancelAllRequests() {
            requestService.cancelAllRequests()
        }

        ///Invalidates all sessions and cancells all tasks.
        public func terminateAllRequests() {
            requestService.invalidateAndCancel()
        }
    }
}

//MARK: Manage simple HTTP requests
public extension Api.Service {

    /**
     Sends HTTP GET request with given parameters.

     - Parameters:
       - url: URL of the receiver.
       - headers: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func getData(from url: URL, with headers: [Api.Header]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(to: url, method: .get, headers: headers, configuration: configuration, completion: completion)
    }

    /**
     Sends HTTP POST request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - headers: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func post(data: Data?, at url: URL, with headers: [Api.Header]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(to: url, with: data, method: .post, headers: headers, configuration: configuration, completion: completion)
    }

    /**
     Sends HTTP PUT request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - headers: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func put(data: Data?, at url: URL, with headers: [Api.Header]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(to: url, with: data, method: .put, headers: headers, configuration: configuration, completion: completion)
    }

    /**
     Sends HTTP PATCH request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - headers: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func patch(data: Data?, at url: URL, with headers: [Api.Header]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(to: url, with: data, method: .patch, headers: headers, configuration: configuration, completion: completion)
    }

    /**
     Sends HTTP DELETE request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - headers: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func delete(data: Data? = nil, at url: URL, with headers: [Api.Header]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(to: url, with: data, method: .delete, headers: headers, configuration: configuration, completion: completion)
    }
}

//MARK: Manage uploading files
public extension Api.Service {

    /**
     Uploads file using HTTP POST request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - headers: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     */
    func postFile(from localFileUrl: URL, to destinationUrl: URL, with headers: [Api.Header]? = nil, configuration: Configuration = .background(), completion: CompletionHandler? = nil) throws -> Task {
        return try uploadFile(from: localFileUrl, to: destinationUrl, with: .post, headers: headers, configuration: configuration, completion: completion)
    }

    /**
     Uploads file using HTTP PUT request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - headers: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     */
    func putFile(from localFileUrl: URL, to destinationUrl: URL, with headers: [Api.Header]? = nil, configuration: Configuration = .background(), completion: CompletionHandler? = nil) throws -> Task {
        return try uploadFile(from: localFileUrl, to: destinationUrl, with: .put, headers: headers, configuration: configuration, completion: completion)
    }

    /**
     Uploads file using HTTP PATCH request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - headers: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     */
    func patchFile(from localFileUrl: URL, to destinationUrl: URL, with headers: [Api.Header]? = nil, configuration: Configuration = .background(), completion: CompletionHandler? = nil) throws -> Task {
        return try uploadFile(from: localFileUrl, to: destinationUrl, with: .patch, headers: headers, configuration: configuration, completion: completion)
    }
}

//MARK: Manage downloading files
public extension Api.Service {

    /**
     Downloads file using HTTP GET request.

     - Parameters:
       - remoteFileUrl: URL of remote file to download.
       - localUrl: URL on disc indicates where file should be saved.
       - headers: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     
     - Important: While using default file manager, if any file exists at *localUrl* it will be overridden by downloaded file.
     */
    func downloadFile(from remoteFileUrl: URL, to localUrl: URL, with headers: [Api.Header]? = nil, configuration: Configuration = .background(), completion: CompletionHandler? = nil) throws -> Task {
        return try downloadFile(from: remoteFileUrl, to: localUrl, apiHeaders: headers, configuration: configuration, completion: completion)
    }
}

//MARK: Methods allowing extend service capabilities
public extension Api.Service {

    /**
     Uploads file using HTTP request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - method: HTTP method which should be used.
       - headers: Array of all aditional HTTP header fields.
       - configuration: Custom or one of predefined *ApiService.Configuration* object.
       - completion: Closure called when request is finished.

     - Returns: Task object which allows to follow progress and manage request.
     
     This method allows to customize every request configuration. It may be very powerfull if you know what you are doing.
     */
    func uploadFile(from localFileUrl: URL, to destinationUrl: URL, with method: Api.Method, headers: [Api.Header]? = nil, configuration: Configuration = .background(), completion: CompletionHandler? = nil) throws -> Task {
        let headers = httpHeaders(for: headers)
        let uploadRequest = Http.UploadRequest(url: destinationUrl, method: method.httpMethod, resourceUrl: localFileUrl, headers: headers)

        return Task(try requestService.send(request: uploadRequest,
                                            with: configuration.requestServiceConfiguration,
                                            completion: requestCompletion(for: completion)))
    }

    /**
    Sends data request with given parameters

    - Parameters:
     - url: URL of the receiver.
     - body: Data object which supposed to be send.
     - method: HTTP method which should be used.
     - headers: Array of all aditional HTTP header fields.
     - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
     - completion: Closure called when request is finished.

    - Returns: Task object which allows to follow progress and manage request.
    */

    func sendRequest(to url: URL, with body: Data? = nil, method: Api.Method, headers: [Api.Header]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        let headers = httpHeaders(for: headers)
        let httpRequest = Http.DataRequest(url: url, method: method.httpMethod, body: body, headers: headers)

        return Task(try requestService.send(request: httpRequest,
                                            with: configuration.requestServiceConfiguration,
                                            completion: requestCompletion(for: completion)))
    }
}

//MARK: Handling background sessions
#if !os(OSX)
public extension Api.Service {

    /**
     Handle events for background session with identifier.

     - Parameters:
       - identifier: The identifier of the URL session requiring attention.
       - completion: The completion handler to call when you finish processing the events.

     - Note: Background tasks works only on real devices, not on simulator.

     This method have to be used in `application(UIApplication, handleEventsForBackgroundURLSession: String, completionHandler: () -> Void)` method of AppDelegate.
     */
    func handleEventsForBackgroundSession(with identifier: String, completion: @escaping () -> Void) {
        requestService.handleEventsForBackgroundSession(with: identifier, completion: completion)
    }
}
#endif

//MARK: Private helpers
private extension Api.Service {

    ///Converts array of *ApiHeader* to array of *HttpHeader*
    func httpHeaders(for apiHeaders: [Api.Header]?) -> [Http.Header]? {
        return apiHeaders?.map { $0.httpHeader }
    }

    ///Creates success and failure action for single completion handler.
    func requestCompletion(for completion: CompletionHandler?) -> Http.Service.CompletionHandler {
        return { (response: Http.Response?, error: Swift.Error?) in
            completion?(Api.Response(response), error)
        }
    }

    ///Downloads file with given parameters
    func downloadFile(from remoteFileUrl: URL, to localUrl: URL, apiHeaders: [Api.Header]?, configuration: Configuration, completion: CompletionHandler?) throws -> Task {
        let headers = httpHeaders(for: apiHeaders)
        let downloadRequest = Http.DownloadRequest(url: remoteFileUrl, destinationUrl: localUrl, headers: headers)

        return Task(try requestService.send(request: downloadRequest,
                                            with: configuration.requestServiceConfiguration,
                                            completion: requestCompletion(for: completion)))
    }
}
