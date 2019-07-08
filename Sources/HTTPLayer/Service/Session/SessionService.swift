//
//  SessionService.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 07.03.2018.
//

import RxSwift

final class SessionService {

    private let urlSession: RxURLSession
    private let sessionQueue:  DispatchQueue
    private let serialScheduler: SerialDispatchQueueScheduler
    private let concurrentScheduler: ConcurrentDispatchQueueScheduler
    private let disposeBag = DisposeBag()
    private var activeCalls = [URLSessionTask: HttpCall]()
    private(set) var isValid = true

    init(configuration: RequestService.Configuration) {
        urlSession = RxURLSession(configuration: configuration.urlSessionConfiguration)
        sessionQueue = DispatchQueue(label: "RxSwiftAPI.SessionService.sessionQueue", qos: .userInteractive)
        serialScheduler = SerialDispatchQueueScheduler(queue: sessionQueue, internalSerialQueueName: "RxSwiftAPI.SessionService.serialScheduler")
        concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "RxSwiftAPI.SessionService.concurrentScheduler", qos: .utility))

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
    func data(request: URLRequest, progress: @escaping SessionServiceProgressHandler, completion: @escaping SessionServiceCompletionHandler) {
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
    func upload(request: URLRequest, file: URL, progress: @escaping SessionServiceProgressHandler, completion: @escaping SessionServiceCompletionHandler) {
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
    func download(request: URLRequest, progress: @escaping SessionServiceProgressHandler, completion: @escaping SessionServiceCompletionHandler) {
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
            self?.isValid = false
            self?.urlSession.invalidateAndCancel()
        }
    }
}

private extension SessionService {

    ///Domain of RxSwiftAPI errors.
    private static let sessionDomain = "RxSwiftAPISessionServiceErrorDomain"

    static func error(_ description: String, code: Int = -20) -> Error {
        return NSError(domain: sessionDomain, code: code, userInfo: [NSLocalizedDescriptionKey : description])
    }

    func safely(add httpCall: HttpCall, and createTask: @escaping () -> URLSessionTask?) {
        sessionQueue.sync { [weak self] in
            guard let `self` = self else {
                httpCall.performCompletion(error: SessionService.error("Lost reference to SessionService."))
                return
            }
            guard self.isValid else {
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

    func completeEveryTask(with error: Error) {
        DispatchQueue.global(qos: .utility).async {
            self.activeCalls.forEach { $0.value.performCompletion(error: error) }
            self.sessionQueue.sync { [weak self] in
                self?.activeCalls.removeAll()
            }
        }
    }

    func setupURLSessionDelegate() {
        urlSession.rx.didBecomeInvalidWithError
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (session: URLSession, error: Error?) in
                self?.isValid = false
                self?.completeEveryTask(with: error ?? SessionService.error("Session invalidated", code: -30))
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionTaskDelegate() {
        urlSession.rx.didSendBodyData
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
                self?.activeCalls[task]?.performProgress(totalBytesProcessed: totalBytesSent, totalBytesExpectedToProcess: totalBytesExpectedToSend)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didCompleteWithError
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionTask, error: Error?) in
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
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionDataTask, response: URLResponse, completion: (URLSession.ResponseDisposition) -> Void) in
                self?.activeCalls[task]?.update(with: response)
                self?.activeCalls[task] != nil ? completion(.allow) : completion(.cancel)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didReceiveData
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionDataTask, response: Data) in
                self?.activeCalls[task]?.update(with: response)
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionDownloadDelegate() {
        urlSession.rx.didFinishDownloading
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionDownloadTask, location: URL) in
                self?.activeCalls[task]?.update(with: location)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didWriteData
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionDownloadTask, bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) in
                self?.activeCalls[task]?.performProgress(totalBytesProcessed: totalBytesWritten, totalBytesExpectedToProcess: totalBytesExpectedToWrite)
            })
            .disposed(by: disposeBag)
    }
}
