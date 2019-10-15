//
//  ApiService.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 13.01.2017.
//

import RxSwift
import RxCocoa


final public class ApiService {

    public typealias CompletionHandler = (_ response: ApiResponse?, _ error: Error?) -> ()

    ///Service managing requests
    let requestService: RequestService

    /**
     - Parameter fileManager: Object of class implementing *FileManager* protocol.
     */
    public init(fileManager: FileManager = DefaultFileManager()) {
        self.requestService = RequestService(fileManager: fileManager)
    }

    ///Cancels all currently running requests.
    public func cancelAllRequests() {
        requestService.cancelAllRequests()
    }
}

///Manage simple HTTP requests
public extension ApiService {

    /**
     Sends HTTP GET request with given parameters.

     - Parameters:
       - url: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func getData(from url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(url: url, method: .get, body: nil, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }

    /**
     Sends HTTP POST request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func post(data: Data?, at url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(url: url, method: .post, body: data, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }

    /**
     Sends HTTP PUT request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func put(data: Data?, at url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(url: url, method: .put, body: data, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }

    /**
     Sends HTTP PATCH request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func patch(data: Data?, at url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(url: url, method: .patch, body: data, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }

    /**
     Sends HTTP DELETE request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func delete(data: Data? = nil, at url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, completion: CompletionHandler? = nil) throws -> Task {
        return try sendRequest(url: url, method: .delete, body: data, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }
}

///Manage uploading files
public extension ApiService {

    /**
     Uploads file using HTTP POST request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func postFile(from localFileUrl: URL, to destinationUrl: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .background, completion: CompletionHandler? = nil) throws -> Task {
        return try uploadFile(at: localFileUrl, to: destinationUrl, method: .post, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }

    /**
     Uploads file using HTTP PUT request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func putFile(from localFileUrl: URL, to destinationUrl: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .background, completion: CompletionHandler? = nil) throws -> Task {
        return try uploadFile(at: localFileUrl, to: destinationUrl, method: .put, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }

    /**
     Uploads file using HTTP PATCH request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func patchFile(from localFileUrl: URL, to destinationUrl: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .background, completion: CompletionHandler? = nil) throws -> Task {
        return try uploadFile(at: localFileUrl, to: destinationUrl, method: .patch, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }
}

///Manage downloading files
public extension ApiService {

    /**
     Downloads file using HTTP GET request.

     - Parameters:
       - remoteFileUrl: URL of remote file to download.
       - localUrl: URL on disc indicates where file should be saved.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     
     - Important: While using default file manager, if any file exists at *localUrl* it will be overridden by downloaded file.
     */
    func downloadFile(from remoteFileUrl: URL, to localUrl: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .background, completion: CompletionHandler? = nil) throws -> Task {
        return try downloadFile(from: remoteFileUrl, to: localUrl, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }
}

///Methods allowing extend service capabilities
public extension ApiService {

    /**
     Uploads file using HTTP request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - method: HTTP method which should be used.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: Custom or one of predefined *ApiService.Configuration* object.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     
     This method allows to customize every request configuration. It may be very powerfull if you know what you are doing.
     */
    func uploadFile(from localFileUrl: URL, to destinationUrl: URL, with method: ApiMethod, aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .background, completion: CompletionHandler? = nil) throws -> Task {
        return try uploadFile(at: localFileUrl, to: destinationUrl, method: method, apiHeaders: aditionalHeaders, configuration: configuration, completion: completion)
    }
}

private extension ApiService {

    ///Converts array of *ApiHeader* to array of *HttpHeader*
    func httpHeaders(for apiHeaders: [ApiHeader]?) -> [HttpHeader]? {
        return apiHeaders?.map { $0.httpHeader }
    }

    ///Creates success and failure action for single completion handler.
    func requestCompletion(for completion: CompletionHandler?) -> RequestService.CompletionHandler {
        return { (response: HttpResponse?, error: Error?) in
            completion?(ApiResponse(response), error)
        }
    }

    ///Sends data request with given parameters
    func sendRequest(url: URL, method: ApiMethod, body: Data?, apiHeaders: [ApiHeader]?, configuration: Configuration, completion: CompletionHandler?) throws -> Task {
        let headers = httpHeaders(for: apiHeaders)
        let action = requestCompletion(for: completion)
        let httpRequest = HttpDataRequest(url: url, method: method.httpMethod, body: body, headers: headers)

        return Task(try requestService.sendHTTP(request: httpRequest,
                                                with: configuration.requestServiceConfiguration,
                                                completion: action))
    }

    ///Uploads file with given parameters
    func uploadFile(at localFileUrl: URL, to destinationUrl: URL, method: ApiMethod, apiHeaders: [ApiHeader]?, configuration: Configuration, completion: CompletionHandler?) throws -> Task {
        let headers = httpHeaders(for: apiHeaders)
        let action = requestCompletion(for: completion)
        let uploadRequest = HttpUploadRequest(url: destinationUrl, method: method.httpMethod, resourceUrl: localFileUrl, headers: headers)

        return Task(try requestService.sendHTTP(request: uploadRequest,
                                                with: configuration.requestServiceConfiguration,
                                                completion: action))
    }

    ///Downloads file with given parameters
    func downloadFile(from remoteFileUrl: URL, to localUrl: URL, apiHeaders: [ApiHeader]?, configuration: Configuration, completion: CompletionHandler?) throws -> Task {
        let headers = httpHeaders(for: apiHeaders)
        let action = requestCompletion(for: completion)
        let downloadRequest = HttpDownloadRequest(url: remoteFileUrl, destinationUrl: localUrl, headers: headers)

        return Task(try requestService.sendHTTP(request: downloadRequest,
                                                with: configuration.requestServiceConfiguration,
                                                completion: action))
    }
}

private extension ApiService {

    func sendHTTP(request: HttpDataRequest, with configuration: Configuration, completion: @escaping RequestService.CompletionHandler) throws -> Task {
        return Task(try requestService.sendHTTP(request: request, with: configuration.requestServiceConfiguration, completion: completion))
    }

    func sendHTTP(request: HttpUploadRequest, with configuration: Configuration, completion: @escaping RequestService.CompletionHandler) throws -> Task {
        return Task(try requestService.sendHTTP(request: request, with: configuration.requestServiceConfiguration, completion: completion))
    }

    func sendHTTP(request: HttpDownloadRequest, with configuration: Configuration, completion: @escaping RequestService.CompletionHandler) throws -> Task {
        return Task(try requestService.sendHTTP(request: request, with: configuration.requestServiceConfiguration, completion: completion))
    }
}
