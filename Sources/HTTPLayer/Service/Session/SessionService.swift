//
//  SessionService.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 07.03.2018.
//

import RxSwift

extension SessionService {
    enum Status {
        case valid
        case invalid
        case invalidated
    }
}

final class SessionService {

    typealias ProgressHandler = (_ totalBytesProcessed: Int64, _ totalBytesExpectedToProcess: Int64) -> ()
    typealias CompletionHandler = (_ response: HttpResponse?, _ error: Error?) -> ()

    private(set) var status = Status.valid
    let configuration: RequestService.Configuration

    private let urlSession: RxURLSession
    private let sessionQueue: DispatchQueue
    private let serialScheduler: SerialDispatchQueueScheduler
    private let concurrentScheduler: ConcurrentDispatchQueueScheduler
    private let disposeBag = DisposeBag()
    private var activeCalls = [URLSessionTask: HttpCall]()

    init(configuration: RequestService.Configuration) {
        self.configuration = configuration
        urlSession = RxURLSession(configuration: configuration.urlSessionConfiguration)
        let timestamp = Date().timeIntervalSince1970
        sessionQueue = DispatchQueue(label: "RxSwiftAPI.SessionService.sessionQueue.\(timestamp)")
        serialScheduler = SerialDispatchQueueScheduler(queue: sessionQueue, internalSerialQueueName: "RxSwiftAPI.SessionService.serialScheduler.\(timestamp)")
        concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "RxSwiftAPI.SessionService.concurrentScheduler.\(timestamp)", qos: .utility))

        DispatchQueue.main.async {
            self.setupURLSessionDelegate()
            self.setupURLSessionTaskDelegate()
            self.setupURLSessionDataDelegate()
            self.setupURLSessionDownloadDelegate()
        }
    }

    deinit {
        invalidateAndCancel()
    }
}

extension SessionService {

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - progress: Block for hangling request progress.
       - completion: Block for hangling request completion.
     */
    func data(request: URLRequest, progress: ProgressHandler?, completion: @escaping CompletionHandler) {
        safely(add: HttpCall(progress: progress, completion: completion)) { [weak self] in
            return self?.urlSession.dataTask(with: request)
        }
    }

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - progress: Block for hangling request progress.
       - completion: Block for hangling request completion.
     */
    func upload(request: URLRequest, file: URL, progress: ProgressHandler?, completion: @escaping CompletionHandler) {
        safely(add: HttpCall(progress: progress, completion: completion)) { [weak self] in
            return self?.urlSession.uploadTask(with: request, fromFile: file)
        }
    }

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - progress: Block for hangling request progress.
       - completion: Block for hangling request completion.
     */
    func download(request: URLRequest, progress: ProgressHandler?, completion: @escaping CompletionHandler) {
        safely(add: HttpCall(progress: progress, completion: completion)) { [weak self] in
            return self?.urlSession.downloadTask(with: request)
        }
    }

    /**
     Temporarily suspends given HTTP request.

     - Parameter request: An URLRequest to suspend.
     */
    func suspend(_ request: URLRequest) {
        forEvery(request) { $0.suspend() }
    }

    /**
     Resumes given HTTP request, if it is suspended.

     - Parameter request: An URLRequest to resume.
     */
    @available(iOS 9.0, OSX 10.11, *)
    func resume(_ request: URLRequest) {
        forEvery(request) { $0.resume() }
    }

    /**
     Cancels given HTTP request.

     - Parameter request: An URLRequest to cancel.
     */
    func cancel(_ request: URLRequest) {
        forEvery(request) { $0.cancel() }
    }

    ///Cancels all currently running HTTP requests.
    func cancelAllRequests() {
        forEvery { $0.cancel() }
    }

    ///Cancels all currently running HTTP requests and invalidates session.
    func invalidateAndCancel() {
        sessionQueue.sync { [weak self] in
            self?.status = .invalid
            self?.urlSession.invalidateAndCancel()
        }
    }
}

extension SessionService: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(urlSession.configuration)
    }

    public static func ==(lhs: SessionService, rhs: SessionService) -> Bool {
        return lhs.urlSession.configuration == rhs.urlSession.configuration
    }
}

private extension SessionService {

    ///Domain of RxSwiftAPI errors.
    private static let sessionDomain = "RxSwiftAPI.SessionService.ErrorDomain"

    static func error(_ description: String, code: Int = -20) -> Error {
        return NSError(domain: sessionDomain, code: code, userInfo: [NSLocalizedDescriptionKey : description])
    }

    func safely(add httpCall: HttpCall, and createTask: @escaping () -> URLSessionTask?) {
        sessionQueue.sync { [weak self] in
            guard let `self` = self else {
                httpCall.performCompletion(error: SessionService.error("Lost reference to SessionService."))
                return
            }
            guard self.status == .valid else {
                httpCall.performCompletion(error: SessionService.error("Attempted to create URLSessionTask in a session that has been invalidated."))
                return
            }
            guard let task = createTask() else {
                httpCall.performCompletion(error: SessionService.error("URLSessionTask could not be created."))
                return
            }
            if let call = self.activeCalls[task], !call.isCompleted {
                httpCall.performCompletion(error: SessionService.error("Attempted to add URLSessionTask which is not completed yet."))
                return
            }
            self.activeCalls[task] = httpCall

            DispatchQueue.global(qos: .utility).async {
                task.resume()
            }
        }
    }

    func forEvery(_ request: URLRequest? = nil, updateTask: @escaping (URLSessionTask) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            if let request = request {
                self.activeCalls.forEach { (task, _) in
                    guard task.currentRequest == request else {
                        return
                    }
                    updateTask(task)
                }
            } else { //If Request is not specified update is performed for every task
                self.activeCalls.forEach { updateTask($0.key) }
            }
        }
    }

    func completeEveryTask(with error: Error, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            self.activeCalls.forEach { $0.value.performCompletion(error: error) }
            self.sessionQueue.sync { [weak self] in
                self?.activeCalls.removeAll()
                completion?()
            }
        }
    }
}

//MARK: Setup observable
private extension SessionService {
    func setupURLSessionDelegate() {
        urlSession.rx.didBecomeInvalidWithError
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] error in
                guard let `self` = self else {
                    return
                }
                if self.status == .valid {
                    self.status = .invalid
                }
                self.completeEveryTask(with: error ?? SessionService.error("Session invalidated", code: -30)) { [weak self] in
                    self?.status = .invalidated
                }
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionTaskDelegate() {
        urlSession.rx.didSendBodyData
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
                self?.activeCalls[task]?.performProgress(totalBytesProcessed: totalBytesSent, totalBytesExpectedToProcess: totalBytesExpectedToSend)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didCompleteWithError
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionTask, error: Error?) in
                defer {
                    self?.activeCalls.removeValue(forKey: task)
                }
                guard let call = self?.activeCalls[task] else {
                    return
                }
                if let error = error {
                    call.performCompletion(error: error)
                    return
                }
                if let taskResponse = task.response {
                    call.update(with: taskResponse)
                }
                guard let response = call.response else {
                    call.performCompletion(error: SessionService.error("Could not create HttpResponse from received response", code: -30))
                    return
                }
                call.performCompletion(response: response)
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionDataDelegate() {
        urlSession.rx.didReceiveResponse
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionDataTask, response: URLResponse, completion: (URLSession.ResponseDisposition) -> Void) in
                self?.activeCalls[task]?.update(with: response)
                self?.activeCalls[task] != nil ? completion(.allow) : completion(.cancel)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didReceiveData
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionDataTask, response: Data) in
                self?.activeCalls[task]?.update(with: response)
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionDownloadDelegate() {
        urlSession.rx.didFinishDownloading
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionDownloadTask, location: URL) in
                self?.activeCalls[task]?.update(with: location)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didWriteData
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionDownloadTask, bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) in
                self?.activeCalls[task]?.performProgress(totalBytesProcessed: totalBytesWritten, totalBytesExpectedToProcess: totalBytesExpectedToWrite)
            })
            .disposed(by: disposeBag)
    }
}
