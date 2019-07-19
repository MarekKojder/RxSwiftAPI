//
//  ApiService.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 13.01.2017.
//

import RxSwift
import RxCocoa

public typealias ApiResponseCompletionHandler = (_ response: ApiResponse?, _ error: Error?) -> ()

final public class ApiService {

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
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func getData(from url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, useProgress: Bool = false, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        return sendRequest(url: url, method: .get, body: nil, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: useProgress, completion: completion)
    }

    /**
     Sends HTTP POST request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func post(data: Data?, at url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, useProgress: Bool = false, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        return sendRequest(url: url, method: .post, body: data, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: useProgress, completion: completion)
    }

    /**
     Sends HTTP PUT request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func put(data: Data?, at url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, useProgress: Bool = false, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        return sendRequest(url: url, method: .put, body: data, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: useProgress, completion: completion)
    }

    /**
     Sends HTTP PATCH request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func patch(data: Data?, at url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, useProgress: Bool = false, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        return sendRequest(url: url, method: .patch, body: data, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: useProgress, completion: completion)
    }

    /**
     Sends HTTP DELETE request with given parameters.

     - Parameters:
       - data: Data object which supposed to be send.
       - url: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: One of predefined *ApiService.Configuration* object containing request configuration.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func delete(data: Data? = nil, at url: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .foreground, useProgress: Bool = false, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        return sendRequest(url: url, method: .delete, body: data, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: useProgress, completion: completion)
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
       - inBackground: Flag indicates if uploading should be performed in background or foreground.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func postFile(from localFileUrl: URL, to destinationUrl: URL, with aditionalHeaders: [ApiHeader]? = nil, inBackground: Bool = true, useProgress: Bool = true, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        let configuration: Configuration = inBackground ? .background : .foreground
        return uploadFile(at: localFileUrl, to: destinationUrl, method: .post, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: useProgress, completion: completion)
    }

    /**
     Uploads file using HTTP PUT request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - inBackground: Flag indicates if uploading should be performed in background or foreground.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func putFile(from localFileUrl: URL, to destinationUrl: URL, with aditionalHeaders: [ApiHeader]? = nil, inBackground: Bool = true, useProgress: Bool = true, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        let configuration: Configuration = inBackground ? .background : .foreground
        return uploadFile(at: localFileUrl, to: destinationUrl, method: .put, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: useProgress, completion: completion)
    }

    /**
     Uploads file using HTTP PATCH request.

     - Parameters:
       - localFileUrl: URL on disc of the resource to upload.
       - destinationUrl: URL of the receiver.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - inBackground: Flag indicates if uploading should be performed in background or foreground.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func patchFile(from localFileUrl: URL, to destinationUrl: URL, with aditionalHeaders: [ApiHeader]? = nil, inBackground: Bool = true, useProgress: Bool = true, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        let configuration: Configuration = inBackground ? .background : .foreground
        return uploadFile(at: localFileUrl, to: destinationUrl, method: .patch, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: useProgress, completion: completion)
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
       - inBackground: Flag indicates if downloading should be performed in background or foreground.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     
     - Important: While using default file manager, if any file exists at *localUrl* it will be overridden by downloaded file.
     */
    func downloadFile(from remoteFileUrl: URL, to localUrl: URL, with aditionalHeaders: [ApiHeader]? = nil, inBackground: Bool = true, useProgress: Bool = true, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        let configuration: Configuration = inBackground ? .background : .foreground
        return downloadFile(from: remoteFileUrl, to: localUrl, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: useProgress, completion: completion)
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
       - progress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.
     
     This method allows to customize every request configuration. It may be very powerfull if you know what you are doing.
     */
    func uploadFile(from localFileUrl: URL, to destinationUrl: URL, with method: ApiMethod, aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .background, progress: Bool = true, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        return uploadFile(at: localFileUrl, to: destinationUrl, method: .patch, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: progress, completion: completion)
    }

    /**
     Downloads file using HTTP GET request.

     - Parameters:
       - remoteFileUrl: URL of remote file to download.
       - localUrl: URL on disc indicates where file should be saved.
       - aditionalHeaders: Array of all aditional HTTP header fields.
       - configuration: Custom or one of predefined *ApiService.Configuration* object.
       - progress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.

     - Returns: ApiRequest object which allows to follow progress and manage request.

     - Important: While using default file manager, if any file exists at *localUrl* it will be overridden by downloaded file.
     
     This method allows to customize every request configuration. It may be very powerfull if you know what you are doing.
     */
    func downloadFile(from remoteFileUrl: URL, to localUrl: URL, with aditionalHeaders: [ApiHeader]? = nil, configuration: Configuration = .background, progress: Bool = true, completion: ApiResponseCompletionHandler? = nil) -> ApiRequest {
        return downloadFile(from: remoteFileUrl, to: localUrl, apiHeaders: aditionalHeaders, configuration: configuration, useProgress: progress, completion: completion)
    }
}

private extension ApiService {

    ///Converts array of *ApiHeader* to array of *HttpHeader*
    func httpHeaders(for apiHeaders: [ApiHeader]?) -> [HttpHeader]? {
        guard let apiHeaders = apiHeaders else {
            return nil
        }
        var headers = [HttpHeader]()
        for header in apiHeaders {
            headers.append(header.httpHeader)
        }
        return headers
    }

    ///Creates success and failure action for single completion handler.
    func requestCompletion(for completion: ApiResponseCompletionHandler?) -> HttpRequestCompletionHandler {
        return { (response: HttpResponse?, error: Error?) in
            completion?(ApiResponse(response), error)
        }
    }

    ///Sends data request with given parameters
    func sendRequest(url: URL, method: ApiMethod, body: Data?, apiHeaders: [ApiHeader]?, configuration: Configuration, useProgress: Bool, completion: ApiResponseCompletionHandler?) -> ApiRequest {
        let headers = httpHeaders(for: apiHeaders)
        let action = requestCompletion(for: completion)
        let httpRequest = HttpDataRequest(url: url, method: method.httpMethod, body: body, headers: headers)

        requestService.sendHTTPRequest(httpRequest, with: configuration.requestServiceConfiguration, progress: nil, completion: action)

        return ApiRequest(httpRequest: httpRequest, httpRequestService: requestService)
    }

    func sendRequest(url: URL, method: ApiMethod, body: Data?, apiHeaders: [ApiHeader]?, configuration: Configuration) -> Single<(ApiResponse)> {
        return Single.create { [weak self] single in
            guard let `self` = self else {
                single(.error(ApiError.unknownError))
                return Disposables.create()
            }
            let headers = self.httpHeaders(for: apiHeaders)
            let httpRequest = HttpDataRequest(url: url, method: method.httpMethod, body: body, headers: headers)
            let request = self.sendHTTPRequest(httpRequest, with: configuration, progress: nil) { (response, error) in
                if let response = ApiResponse(response) {
                    single(.success(response))
                } else {
                    single(.error(error ?? ApiError.unknownError))
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }

    func sendRequest(url: URL, method: ApiMethod, body: Data?, apiHeaders: [ApiHeader]?, configuration: Configuration) -> Observable<(Progress?, ApiResponse?)> {
        return Observable.create { [weak self] observable in
            guard let `self` = self else {
                observable.onError(ApiError.unknownError)
                return Disposables.create()
            }

            let headers = self.httpHeaders(for: apiHeaders)
            let httpRequest = HttpDataRequest(url: url, method: method.httpMethod, body: body, headers: headers)

            self.requestService.sendHTTPRequest(httpRequest, with: configuration.requestServiceConfiguration, progress: nil) { (response, error) in
                if let response = ApiResponse(response) {
                    observable.onNext((nil, response))
                } else {
                    observable.onError(error ?? ApiError.unknownError)
                }
            }
            return Disposables.create { [weak self] in
                self?.requestService.cancel(httpRequest)
            }
        }
    }




    ///Uploads file with given parameters
    func uploadFile(at localFileUrl: URL, to destinationUrl: URL, method: ApiMethod, apiHeaders: [ApiHeader]?, configuration: Configuration, useProgress: Bool, completion: ApiResponseCompletionHandler?) -> ApiRequest  {
        let headers = httpHeaders(for: apiHeaders)
        let action = requestCompletion(for: completion)
        let uploadRequest = HttpUploadRequest(url: destinationUrl, method: method.httpMethod, resourceUrl: localFileUrl, headers: headers)

        requestService.sendHTTPRequest(uploadRequest, with: configuration.requestServiceConfiguration, progress: nil, completion: action)

        return ApiRequest(httpRequest: uploadRequest, httpRequestService: requestService)
    }

    ///Downloads file with given parameters
    func downloadFile(from remoteFileUrl: URL, to localUrl: URL, apiHeaders: [ApiHeader]?, configuration: Configuration, useProgress: Bool, completion: ApiResponseCompletionHandler?) -> ApiRequest  {
        let headers = httpHeaders(for: apiHeaders)
        let action = requestCompletion(for: completion)
        let downloadRequest = HttpDownloadRequest(url: remoteFileUrl, destinationUrl: localUrl, headers: headers)

        requestService.sendHTTPRequest(downloadRequest, with: configuration.requestServiceConfiguration, progress: nil, completion: action)

        return ApiRequest(httpRequest: downloadRequest, httpRequestService: requestService)
    }
}

private extension ApiService {

    func sendHTTPRequest(_ request: HttpDataRequest, with configuration: Configuration = .foreground, progress: SessionServiceProgressHandler?, completion: @escaping HttpRequestCompletionHandler) -> ApiRequest {
        requestService.sendHTTPRequest(request, with: configuration.requestServiceConfiguration, progress: progress, completion: completion)
        return ApiRequest(httpRequest: request, httpRequestService: requestService)
    }

    func sendHTTPRequest(_ request: HttpUploadRequest, with configuration: Configuration = .background, progress: SessionServiceProgressHandler?, completion: @escaping HttpRequestCompletionHandler) -> ApiRequest {
        requestService.sendHTTPRequest(request, with: configuration.requestServiceConfiguration, progress: progress, completion: completion)
        return ApiRequest(httpRequest: request, httpRequestService: requestService)
    }

    func sendHTTPRequest(_ request: HttpDownloadRequest, with configuration: Configuration = .background, progress: SessionServiceProgressHandler?, completion: @escaping HttpRequestCompletionHandler) -> ApiRequest {
        requestService.sendHTTPRequest(request, with: configuration.requestServiceConfiguration, progress: progress, completion: completion)
        return ApiRequest(httpRequest: request, httpRequestService: requestService)
    }
}
