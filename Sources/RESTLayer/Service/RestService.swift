//
//  RestService.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 03.02.2017.
//
import Foundation

public class RestService {

    ///Base URL of API server. Remember not to finish it with */* sign.
    public let baseUrl: String

    ///Path of API on server. May be used for versioning. Remember to start it with */* sign.
    public let apiPath: String?

    ///Array of aditional HTTP header fields.
    private let headerFields: [ApiHeader]?

    ///Provider of decoder and encoder.
    private let coder: CoderProvider

    ///Service for managing request with REST server.
    let apiService: ApiService

    /**
     - Parameters:
       - baseUrl: Base URL string of API server.
       - apiPath: Path of API on server.
       - headerFields: Array of HTTP header fields which will be added to all requests. By default ContentType.json is set.
       - coderProvider: Object providing *JSONCoder* and *JSONDecoder*.
       - fileManager: Object of class implementing *FileManager* Protocol.
     */
    public init(baseUrl: String, apiPath: String? = nil, headerFields: [ApiHeader]? = [ApiHeader.ContentType.json], coderProvider: CoderProvider = DefaultCoderProvider(), fileManager: FileManager = DefaultFileManager()) {
        self.baseUrl = baseUrl
        self.apiPath = apiPath
        self.headerFields = headerFields
        self.coder = coderProvider
        self.apiService = ApiService(fileManager: fileManager)
    }
}

//MARK: Simple requests
public extension RestService {

    /**
     Sends HTTP GET request.
     - Parameters:
       - type: Type conforming *Decodable* protocol which should be returned in completion block.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func get<Response: Decodable>(type: Response.Type, from path: ResourcePath, with aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, completion: RestResponseCompletionHandler<Response>? = nil) throws -> ApiRequest {
        let parameters: EmptyData? = nil
        return try get(type: type,
                       from: path,
                       parameters: parameters,
                       aditionalHeaders: aditionalHeaders,
                       useProgress: useProgress,
                       inBackground: inBackground,
                       completion: completion)
    }

    /**
     Sends HTTP GET request.
     - Parameters:
       - type: Type conforming *Decodable* protocol which should be returned in completion block.
       - path: Path of the resource.
       - parameters: Query items for request.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - completion: Closure called when request is finished.
       - Throws: RestService.Error if creating *URL* failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func get<Parameters: Encodable, Response: Decodable>(type: Response.Type, from path: ResourcePath, parameters: Parameters, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, completion: RestResponseCompletionHandler<Response>? = nil) throws -> ApiRequest {
        return apiService.getData(from: try requestUrl(for: path, with: parameters),
                                  with: apiHeaders(adding: aditionalHeaders),
                                  configuration: inBackground ? .background : .foreground,
                                  useProgress: useProgress,
                                  completion: completionHandler(for: type, coder: coder, with: completion))
    }

    /**
     Sends HTTP POST request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - responseType: Type conforming *Decodable* protocol which should be returned in completion block.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func post<Request: Encodable, Response: Decodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, responseType: Response.Type? = nil, completion: RestResponseCompletionHandler<Response>? = nil) throws -> ApiRequest {
        return try post(value,
                        at: path,
                        aditionalHeaders: aditionalHeaders,
                        useProgress: useProgress,
                        inBackground: inBackground,
                        completion: completionHandler(for: Response.self, coder: coder, with: completion))
    }

    /**
     Sends HTTP POST request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func post<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, completion: RestSimpleResponseCompletionHandler? = nil) throws -> ApiRequest {
        return try post(value,
                        at: path,
                        aditionalHeaders: aditionalHeaders,
                        useProgress: useProgress,
                        inBackground: inBackground,
                        completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP PUT request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - responseType: Type conforming *Decodable* protocol which should be returned in completion block.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func put<Request: Encodable, Response: Decodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, responseType: Response.Type? = nil, completion: RestResponseCompletionHandler<Response>? = nil) throws -> ApiRequest {
        return try put(value,
                       at: path,
                       aditionalHeaders: aditionalHeaders,
                       useProgress: useProgress,
                       inBackground: inBackground,
                       completion: completionHandler(for: Response.self, coder: coder, with: completion))
    }

    /**
     Sends HTTP PUT request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func put<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, completion: RestSimpleResponseCompletionHandler? = nil) throws -> ApiRequest {
        return try put(value,
                       at: path,
                       aditionalHeaders: aditionalHeaders,
                       useProgress: useProgress,
                       inBackground: inBackground,
                       completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP PATCH request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - responseType: Type conforming *Decodable* protocol which should be returned in completion block.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func patch<Request: Encodable, Response: Decodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, responseType: Response.Type? = nil, completion: RestResponseCompletionHandler<Response>? = nil) throws -> ApiRequest {
        return try patch(value,
                         at: path,
                         aditionalHeaders: aditionalHeaders,
                         useProgress: useProgress,
                         inBackground: inBackground,
                         completion: completionHandler(for: Response.self, coder: coder, with: completion))
    }

    /**
     Sends HTTP PATCH request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func patch<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, completion: RestSimpleResponseCompletionHandler? = nil) throws -> ApiRequest {
        return try patch(value,
                         at: path,
                         aditionalHeaders: aditionalHeaders,
                         useProgress: useProgress,
                         inBackground: inBackground,
                         completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP DELETE request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - responseType: Type conforming *Decodable* protocol which should be returned in completion block.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func delete<Request: Encodable, Response: Decodable>(_ value: Request? = nil, at path: ResourcePath, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, responseType: Response.Type? = nil, completion: RestResponseCompletionHandler<Response>? = nil) throws -> ApiRequest {
        return try delete(value,
                          at: path,
                          aditionalHeaders: aditionalHeaders,
                          useProgress: useProgress,
                          inBackground: inBackground,
                          completion: completionHandler(for: Response.self, coder: coder, with: completion))
    }

    /**
     Sends HTTP DELETE request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - inBackground: Flag indicates if request should be performed in background or foreground.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    @discardableResult
    func delete<Request: Encodable>(_ value: Request? = nil, at path: ResourcePath, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = false, inBackground: Bool = false, completion: RestSimpleResponseCompletionHandler? = nil) throws -> ApiRequest {
        return try delete(value,
                          at: path,
                          aditionalHeaders: aditionalHeaders,
                          useProgress: useProgress,
                          inBackground: inBackground,
                          completion: completionHandler(with: completion))
    }
}

//MARK: File managing
public extension RestService {

    /**
     Sends HTTP GET request for file.
     - Parameters:
       - path: Path of file to download.
       - destinationUrl: Local url, where file should be saved.
       - inBackground: Flag indicates if downloading should be performed in background or foreground.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func getFile(at path: ResourcePath, saveAt destinationUrl: URL, inBackground: Bool = true, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = true, completion: RestSimpleResponseCompletionHandler? = nil) throws -> ApiRequest {
        let parameters: EmptyData? = nil
        return try getFile(at: path, parameters: parameters, saveAt: destinationUrl, inBackground: inBackground, aditionalHeaders: aditionalHeaders, useProgress: useProgress, completion: completion)
    }

    /**
     Sends HTTP GET request for file.
     - Parameters:
       - path: Path of file to download.
       - parameters: Query items for request.
       - destinationUrl: Local url, where file should be saved.
       - inBackground: Flag indicates if downloading should be performed in background or foreground.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func getFile<Parameters: Encodable>(at path: ResourcePath, parameters: Parameters?, saveAt destinationUrl: URL, inBackground: Bool = true, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = true, completion: RestSimpleResponseCompletionHandler? = nil) throws -> ApiRequest {
        let url = try requestUrl(for: path, with: parameters)
        let headers = apiHeaders(adding: aditionalHeaders)
        let completion = completionHandler(with: completion)
        return apiService.downloadFile(from: url, to: destinationUrl, with: headers, inBackground: inBackground, useProgress: useProgress, completion: completion)
    }

    /**
     Sends HTTP POST request with file.
     - Parameters:
       - url: Local url, where file should be saved.
       - path: Destination path of file.
       - inBackground: Flag indicates if downloading should be performed in background or foreground.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func postFile(from url: URL, at path: ResourcePath, inBackground: Bool = true, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = true, completion: RestSimpleResponseCompletionHandler? = nil) throws -> ApiRequest {
        let destinationUrl = try requestUrl(for: path)
        let headers = apiHeaders(adding: aditionalHeaders)
        let completion = completionHandler(with: completion)
        return apiService.postFile(from: url, to: destinationUrl, with: headers, inBackground: inBackground, useProgress: useProgress, completion: completion)
    }

    /**
     Sends HTTP PUT request with file.
     - Parameters:
       - url: Local url, where file should be saved.
       - path: Destination path of file.
       - inBackground: Flag indicates if downloading should be performed in background or foreground.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func putFile(from url: URL, at path: ResourcePath, inBackground: Bool = true, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = true, completion: RestSimpleResponseCompletionHandler? = nil) throws -> ApiRequest {
        let destinationUrl = try requestUrl(for: path)
        let headers = apiHeaders(adding: aditionalHeaders)
        let completion = completionHandler(with: completion)
        return apiService.putFile(from: url, to: destinationUrl, with: headers, inBackground: inBackground, useProgress: useProgress, completion: completion)
    }

    /**
     Sends HTTP PATCH request with file.
     - Parameters:
       - url: Local url, where file should be saved.
       - path: Destination path of file.
       - inBackground: Flag indicates if downloading should be performed in background or foreground.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - useProgress: Flag indicates if Progress object should be created.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* failed.
     - Returns: ApiRequest object which allows to follow progress and manage request.
     */
    func patchFile(from url: URL, at path: ResourcePath, inBackground: Bool = true, aditionalHeaders: [ApiHeader]? = nil, useProgress: Bool = true, completion: RestSimpleResponseCompletionHandler? = nil) throws -> ApiRequest {
        let destinationUrl = try requestUrl(for: path)
        let headers = apiHeaders(adding: aditionalHeaders)
        let completion = completionHandler(with: completion)
        return apiService.patchFile(from: url, to: destinationUrl, with: headers, inBackground: inBackground, useProgress: useProgress, completion: completion)
    }
}

//MARK: Requests managing
public extension RestService {

    ///Cancels all currently running requests.
    func cancelAllRequests() {
        apiService.cancelAllRequests()
    }
}

//MARK: - Parameter factories
private extension RestService {

    struct EmptyData: Codable {}

    ///Creates full url by joining `baseUrl`, `apiPath` and given `path`.
    func requestUrl(for path: ResourcePath) throws -> URL {
        let url: String
        if let apiPath = apiPath, !apiPath.isEmpty {
            url = baseUrl.appending(apiPath).appending(path.rawValue)
        } else {
            url = baseUrl.appending(path.rawValue)
        }
        guard let finalUrl = URL(string: url) else {
            throw RestService.Error.url
        }
        return finalUrl
    }

    ///Creates full url by joining `baseUrl`, `apiPath` given `path` and `parameters`.
    func requestUrl<T: Encodable>(for path: ResourcePath, with parameters: T?) throws -> URL {
        let fullUrl = try requestUrl(for: path)
        guard let parameters = parameters else {
            return fullUrl
        }
        let data = try coder.encode(parameters)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any?] else {
            let message = "Could not encode parameters to [String : Any?] dictionary!"
            throw EncodingError.invalidValue(parameters, EncodingError.Context(codingPath: [], debugDescription: message))
        }
        if dictionary.isEmpty {
            return fullUrl
        }
        guard var components = URLComponents(url: fullUrl, resolvingAgainstBaseURL: false) else {
            throw RestService.Error.urlComponents
        }
        var items = components.queryItems ?? [URLQueryItem]()
        let itemsToAppend = dictionary.map({ URLQueryItem(name: $0.key, value: $0.value != nil ? "\($0.value!)" : nil) })
        items.append(contentsOf: itemsToAppend)
        components.queryItems = items

        guard let urlWithParameters = components.url else {
            throw RestService.Error.url
        }
        return urlWithParameters
    }

    ///Merges `headerFields` with giver aditional `headers`.
    func apiHeaders(adding headers: [ApiHeader]?) -> [ApiHeader]? {
        guard let headerFields = headerFields else {
            return headers
        }
        guard let headers = headers else {
            return headerFields
        }
        var mergedHeders = headerFields
        for header in headers {
            if let index = mergedHeders.firstIndex(where: { $0.name == header.name }) {
                mergedHeders.remove(at: index)
            }
            mergedHeders.append(header)
        }
        return mergedHeders
    }

    ///Encodes encodable `value` into *Data* object.
    func requestData<T: Encodable>(for value: T?) throws -> Data? {
        guard let value = value else {
            return nil
        }
        return try coder.encode(value)
    }

    ///Converts *RestResponseCompletionHandler* into *ApiResponseCompletionHandler*.
    func completionHandler<Response: Decodable>(for type: Response.Type?, coder: CoderProvider, with completion: RestResponseCompletionHandler<Response>?) -> ApiResponseCompletionHandler? {
        guard let completion = completion, let type = type else {
            return nil
        }
        return { (response, error) in
            guard let response = response, error == nil else {
                completion(nil, RestResponseDetails(error))
                return
            }
            var details = RestResponseDetails(response)
            guard let body = response.body else {
                completion(nil, details)
                return
            }
            do {
                let decodedData = try coder.decode(type, from: body)
                completion(decodedData, details)
            } catch {
                details.error = error
                completion(nil, details)
            }
        }
    }

    ///Converts *SimpleRestResponseCompletionHandler* into *ApiResponseCompletionHandler*.
    func completionHandler(with completion: RestSimpleResponseCompletionHandler?) -> ApiResponseCompletionHandler? {
        guard let completion = completion else {
            return nil
        }
        return { (response, error) in
            guard let response = response, error == nil else {
                completion(false, RestResponseDetails(error))
                return
            }
            completion(response.statusCode.isSuccess, RestResponseDetails(response))
        }
    }
}

private extension RestService {

    ///Posts given `value` using `apiService`.
    func post<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]?, useProgress: Bool, inBackground: Bool, completion: ApiResponseCompletionHandler?) throws -> ApiRequest {
        return apiService.post(data: try requestData(for: value),
                               at: try requestUrl(for: path),
                               with: apiHeaders(adding: aditionalHeaders),
                               configuration: inBackground ? .background : .foreground,
                               useProgress: useProgress,
                               completion: completion)
    }

    ///Puts given `value` using `apiService`.
    func put<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]?, useProgress: Bool, inBackground: Bool, completion: ApiResponseCompletionHandler?) throws -> ApiRequest {
        return apiService.put(data: try requestData(for: value),
                              at: try requestUrl(for: path),
                              with: apiHeaders(adding: aditionalHeaders),
                              configuration: inBackground ? .background : .foreground,
                              useProgress: useProgress,
                              completion: completion)
    }

    ///Patches given `value` using `apiService`.
    func patch<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]?, useProgress: Bool, inBackground: Bool, completion: ApiResponseCompletionHandler?) throws -> ApiRequest {
        return apiService.patch(data: try requestData(for: value),
                                at: try requestUrl(for: path),
                                with: apiHeaders(adding: aditionalHeaders),
                                configuration: inBackground ? .background : .foreground,
                                useProgress: useProgress,
                                completion: completion)
    }

    ///Deletes given `value` using `apiService`.
    func delete<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [ApiHeader]?, useProgress: Bool, inBackground: Bool, completion: ApiResponseCompletionHandler?) throws -> ApiRequest {
        return apiService.delete(data: try requestData(for: value),
                                 at: try requestUrl(for: path),
                                 with: apiHeaders(adding: aditionalHeaders),
                                 configuration: inBackground ? .background : .foreground,
                                 useProgress: useProgress,
                                 completion: completion)
    }
}
