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
    private let headerFields: [Api.Header]?

    ///Provider of decoder and encoder.
    private let coder: CoderProvider

    ///Service for managing request with REST server.
    private let apiService: Api.Service

    /**
     - Parameters:
       - baseUrl: Base URL string of API server.
       - apiPath: Path of API on server.
       - headerFields: Array of HTTP header fields which will be added to all requests. By default ContentType.json is set.
       - coderProvider: Object providing *JSONCoder* and *JSONDecoder*.
       - fileManager: Object of class implementing *FileManager* Protocol.
     */
    public init(baseUrl: String, apiPath: String? = nil, headerFields: [Api.Header]? = [Api.Header.ContentType.json], coderProvider: CoderProvider = DefaultCoderProvider(), fileManager: FileManager = DefaultFileManager()) {
        self.baseUrl = baseUrl
        self.apiPath = apiPath
        self.headerFields = headerFields
        self.coder = coderProvider
        self.apiService = Api.Service(fileManager: fileManager)
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
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func get<Response: Decodable>(type: Response.Type, from path: ResourcePath, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, completion: RestResponse.CompletionHandler<Response>? = nil) throws -> Api.Service.Task {
        return try apiService.getData(from: try requestUrl(for: path),
                                      with: apiHeaders(adding: aditionalHeaders),
                                      configuration: configuration,
                                      completion: completionHandler(coder: coder, with: completion))
    }

    /**
     Sends HTTP GET request.
     - Parameters:
       - type: Type conforming *Decodable* protocol which should be returned in completion block.
       - path: Path of the resource.
       - parameters: Query items for request.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func get<Parameters: Encodable, Response: Decodable>(type: Response.Type, from path: ResourcePath, parameters: Parameters, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, completion: RestResponse.CompletionHandler<Response>? = nil) throws -> Api.Service.Task {
        return try apiService.getData(from: try requestUrl(for: path, with: parameters),
                                      with: apiHeaders(adding: aditionalHeaders),
                                      configuration: configuration,
                                      completion: completionHandler(coder: coder, with: completion))
    }

    /**
     Sends HTTP POST request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - responseType: Type conforming *Decodable* protocol which should be returned in completion block.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func post<Request: Encodable, Response: Decodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, responseType: Response.Type? = nil, completion: RestResponse.CompletionHandler<Response>? = nil) throws -> Api.Service.Task {
        return try post(value,
                        at: path,
                        aditionalHeaders: aditionalHeaders,
                        configuration: configuration,
                        completion: completionHandler(coder: coder, with: completion))
    }

    /**
     Sends HTTP POST request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func post<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, completion: RestResponse.SimpleCompletionHandler? = nil) throws -> Api.Service.Task {
        return try post(value,
                        at: path,
                        aditionalHeaders: aditionalHeaders,
                        configuration: configuration,
                        completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP PUT request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - responseType: Type conforming *Decodable* protocol which should be returned in completion block.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func put<Request: Encodable, Response: Decodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, responseType: Response.Type? = nil, completion: RestResponse.CompletionHandler<Response>? = nil) throws -> Api.Service.Task {
        return try put(value,
                       at: path,
                       aditionalHeaders: aditionalHeaders,
                       configuration: configuration,
                       completion: completionHandler(coder: coder, with: completion))
    }

    /**
     Sends HTTP PUT request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func put<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, completion: RestResponse.SimpleCompletionHandler? = nil) throws -> Api.Service.Task {
        return try put(value,
                       at: path,
                       aditionalHeaders: aditionalHeaders,
                       configuration: configuration,
                       completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP PATCH request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - responseType: Type conforming *Decodable* protocol which should be returned in completion block.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func patch<Request: Encodable, Response: Decodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, responseType: Response.Type? = nil, completion: RestResponse.CompletionHandler<Response>? = nil) throws -> Api.Service.Task {
        return try patch(value,
                         at: path,
                         aditionalHeaders: aditionalHeaders,
                         configuration: configuration,
                         completion: completionHandler(coder: coder, with: completion))
    }

    /**
     Sends HTTP PATCH request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func patch<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, completion: RestResponse.SimpleCompletionHandler? = nil) throws -> Api.Service.Task {
        return try patch(value,
                         at: path,
                         aditionalHeaders: aditionalHeaders,
                         configuration: configuration,
                         completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP DELETE request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - responseType: Type conforming *Decodable* protocol which should be returned in completion block.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func delete<Request: Encodable, Response: Decodable>(_ value: Request? = nil, at path: ResourcePath, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, responseType: Response.Type? = nil, completion: RestResponse.CompletionHandler<Response>? = nil) throws -> Api.Service.Task {
        return try delete(value,
                          at: path,
                          aditionalHeaders: aditionalHeaders,
                          configuration: configuration,
                          completion: completionHandler(coder: coder, with: completion))
    }

    /**
     Sends HTTP DELETE request.
     - Parameters:
       - value: Value of type conforming *Encodable* protocol which data should be sent with request.
       - path: Path of the resource.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed or JSONEncoder error if encoding given value failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    @discardableResult
    func delete<Request: Encodable>(_ value: Request? = nil, at path: ResourcePath, aditionalHeaders: [Api.Header]? = nil, configuration: Api.Service.Configuration = .foreground, completion: RestResponse.SimpleCompletionHandler? = nil) throws -> Api.Service.Task {
        return try delete(value,
                          at: path,
                          aditionalHeaders: aditionalHeaders,
                          configuration: configuration,
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
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    func getFile(at path: ResourcePath, saveAt destinationUrl: URL, configuration: Api.Service.Configuration = .background(), aditionalHeaders: [Api.Header]? = nil, completion: RestResponse.SimpleCompletionHandler? = nil) throws -> Api.Service.Task {
        return try apiService.downloadFile(from: try requestUrl(for: path),
                                           to: destinationUrl,
                                           with: apiHeaders(adding: aditionalHeaders),
                                           configuration: configuration,
                                           completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP GET request for file.
     - Parameters:
       - path: Path of file to download.
       - parameters: Query items for request.
       - destinationUrl: Local url, where file should be saved.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    func getFile<Parameters: Encodable>(at path: ResourcePath, parameters: Parameters?, saveAt destinationUrl: URL, configuration: Api.Service.Configuration = .background(), aditionalHeaders: [Api.Header]? = nil, completion: RestResponse.SimpleCompletionHandler? = nil) throws -> Api.Service.Task {
        return try apiService.downloadFile(from: try requestUrl(for: path, with: parameters),
                                           to: destinationUrl,
                                           with: apiHeaders(adding: aditionalHeaders),
                                           configuration: configuration,
                                           completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP POST request with file.
     - Parameters:
       - url: Local url, where file should be saved.
       - path: Destination path of file.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    func postFile(from url: URL, at path: ResourcePath, configuration: Api.Service.Configuration = .background(), aditionalHeaders: [Api.Header]? = nil, completion: RestResponse.SimpleCompletionHandler? = nil) throws -> Api.Service.Task? {
        return try apiService.postFile(from: url,
                                       to: try requestUrl(for: path),
                                       with: apiHeaders(adding: aditionalHeaders),
                                       configuration: configuration,
                                       completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP PUT request with file.
     - Parameters:
       - url: Local url, where file should be saved.
       - path: Destination path of file.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    func putFile(from url: URL, at path: ResourcePath, configuration: Api.Service.Configuration = .background(), aditionalHeaders: [Api.Header]? = nil, completion: RestResponse.SimpleCompletionHandler? = nil) throws -> Api.Service.Task? {
        return try apiService.putFile(from: url,
                                      to: try requestUrl(for: path),
                                      with: apiHeaders(adding: aditionalHeaders),
                                      configuration: configuration,
                                      completion: completionHandler(with: completion))
    }

    /**
     Sends HTTP PATCH request with file.
     - Parameters:
       - url: Local url, where file should be saved.
       - path: Destination path of file.
       - configuration: One of predefined *ApiService.Configuration* containing request configuration.
       - aditionalHeaders: Additional header fields which should be sent with request.
       - completion: Closure called when request is finished.
     - Throws: RestService.Error if creating *URL* have failed.
     - Returns: ApiService.Task object which allows to follow progress and manage request.
     */
    func patchFile(from url: URL, at path: ResourcePath, configuration: Api.Service.Configuration = .background(), aditionalHeaders: [Api.Header]? = nil, completion: RestResponse.SimpleCompletionHandler? = nil) throws -> Api.Service.Task? {
        return try apiService.patchFile(from: url,
                                        to: try requestUrl(for: path),
                                        with: apiHeaders(adding: aditionalHeaders),
                                        configuration: configuration,
                                        completion: completionHandler(with: completion))
    }
}

//MARK: Requests managing
public extension RestService {

    ///Cancels all currently running requests.
    func cancelAllRequests() {
        apiService.cancelAllRequests()
    }

    ///Invalidates all sessions and cancells all tasks.
    func terminateAllRequests() {
        apiService.terminateAllRequests()
    }
}

//MARK: Handling background sessions
#if !os(OSX)
public extension RestService {

    /**
     Handle events for background session with identifier.
     - Parameters:
       - identifier: The identifier of the URL session requiring attention.
       - completion: The completion handler to call when you finish processing the events.
     This method have to be used in `application(UIApplication, handleEventsForBackgroundURLSession: String, completionHandler: () -> Void)` method of AppDelegate.
     */
    func handleEventsForBackgroundSession(with identifier: String, completion: @escaping () -> Void) {
        apiService.handleEventsForBackgroundSession(with: identifier, completion: completion)
    }
}
#endif

//MARK: - Parameter factories
private extension RestService {

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
    func apiHeaders(adding headers: [Api.Header]?) -> [Api.Header]? {
        guard let headerFields = headerFields else {
            return headers
        }
        guard let headers = headers else {
            return headerFields
        }
        let headersSet = Set(headers).union(headerFields)
        return Array(headersSet)
    }

    ///Encodes encodable `value` into *Data* object.
    func requestData<T: Encodable>(for value: T?) throws -> Data? {
        guard let value = value else {
            return nil
        }
        return try coder.encode(value)
    }

    ///Converts *RestResponseCompletionHandler* into *ApiResponseCompletionHandler*.
    func completionHandler<Response: Decodable>(coder: CoderProvider, with completion: RestResponse.CompletionHandler<Response>?) -> Api.Service.CompletionHandler? {
        guard let completion = completion else {
            return nil
        }
        return { (response, error) in
            guard let response = response, error == nil else {
                completion(nil, RestResponse.Details(error))
                return
            }
            var details = RestResponse.Details(response)
            guard let body = response.body else {
                completion(nil, details)
                return
            }
            do {
                let decodedData = try coder.decode(Response.self, from: body)
                completion(decodedData, details)
            } catch {
                details.error = error
                completion(nil, details)
            }
        }
    }

    ///Converts *SimpleRestResponseCompletionHandler* into *ApiResponseCompletionHandler*.
    func completionHandler(with completion: RestResponse.SimpleCompletionHandler?) -> Api.Service.CompletionHandler? {
        guard let completion = completion else {
            return nil
        }
        return { (response, error) in
            guard let response = response, error == nil else {
                completion(false, RestResponse.Details(error))
                return
            }
            completion(response.statusCode.isSuccess, RestResponse.Details(response))
        }
    }
}

private extension RestService {

    ///Posts given `value` using `apiService`.
    func post<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]?, configuration: Api.Service.Configuration, completion: Api.Service.CompletionHandler?) throws -> Api.Service.Task {
        return try apiService.post(data: try requestData(for: value),
                                   at: try requestUrl(for: path),
                                   with: apiHeaders(adding: aditionalHeaders),
                                   configuration: configuration,
                                   completion: completion)
    }

    ///Puts given `value` using `apiService`.
    func put<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]?, configuration: Api.Service.Configuration, completion: Api.Service.CompletionHandler?) throws -> Api.Service.Task {
        return try apiService.put(data: try requestData(for: value),
                                  at: try requestUrl(for: path),
                                  with: apiHeaders(adding: aditionalHeaders),
                                  configuration: configuration,
                                  completion: completion)
    }

    ///Patches given `value` using `apiService`.
    func patch<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]?, configuration: Api.Service.Configuration, completion: Api.Service.CompletionHandler?) throws -> Api.Service.Task {
        return try apiService.patch(data: try requestData(for: value),
                                    at: try requestUrl(for: path),
                                    with: apiHeaders(adding: aditionalHeaders),
                                    configuration: configuration,
                                    completion: completion)
    }

    ///Deletes given `value` using `apiService`.
    func delete<Request: Encodable>(_ value: Request?, at path: ResourcePath, aditionalHeaders: [Api.Header]?, configuration: Api.Service.Configuration, completion: Api.Service.CompletionHandler?) throws -> Api.Service.Task {
        return try apiService.delete(data: try requestData(for: value),
                                     at: try requestUrl(for: path),
                                     with: apiHeaders(adding: aditionalHeaders),
                                     configuration: configuration,
                                     completion: completion)
    }
}
