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

    typealias ProgressHandler = (_ progress: Progress) -> ()
    typealias CompletionHandler = (_ response: HttpResponse?, _ error: Error?) -> ()

    private(set) var status = Status.valid
    let configuration: RequestService.Configuration

    private let urlSession: RxURLSession
    private let sessionQueue: DispatchQueue
    private let serialScheduler: SerialDispatchQueueScheduler
    private let concurrentScheduler: ConcurrentDispatchQueueScheduler
    private let disposeBag = DisposeBag()
    private var activeTasks = [Task]()

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
        safely(add: progress, completion: completion) { [weak self] in
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
        safely(add: progress, completion: completion) { [weak self] in
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
        safely(add: progress, completion: completion) { [weak self] in
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
        let group = DispatchGroup()
        activeTasks.forEach { task in
            group.enter()
            task.cancel {
                group.leave()
            }
        }
        group.notify(queue: sessionQueue) { [weak self] in
            self?.activeTasks.removeAll()
        }
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

    static func error(_ description: String, code: Int) -> Error {
        return NSError(domain: sessionDomain, code: code, userInfo: [NSLocalizedDescriptionKey : description])
    }

    func safely(add progress: ProgressHandler?, completion: @escaping CompletionHandler, and createTask: @escaping () -> URLSessionTask?) {
        sessionQueue.sync { [weak self] in
            guard let `self` = self else {
                completion(nil, SessionService.error("Lost reference to SessionService.", code: -1))
                return
            }
            guard self.status == .valid else {
                completion(nil, SessionService.error("Attempted to create URLSessionTask in a session that has been invalidated.", code: -2))
                return
            }
            guard let urlSessionTask = createTask() else {
                completion(nil, SessionService.error("URLSessionTask could not be created.", code: -3))
                return
            }
            if let index = self.activeTasks.lastIndex(where: { $0 == urlSessionTask }) {
                switch self.activeTasks[index].status {
                case .running,
                     .suspend:
                    self.activeTasks[index].append(progress: progress, completion: completion)
                    return
                case .finished:
                    self.activeTasks.remove(at: index)
                default:
                    break
                }
            }
            let task = Task(task: urlSessionTask, progress: progress, completion: completion)
            self.activeTasks.append(task)

            DispatchQueue.global(qos: .utility).async {
                task.resume()
            }
        }
    }

    func forEvery(_ request: URLRequest, updateTask: @escaping (Task) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            self.activeTasks.forEach { task in
                guard task.request == request else {
                    return
                }
                updateTask(task)
            }
        }
    }
}

extension SessionService.Task {
    var cancelationError: Error {
        let description = "Cancelled!"
        return NSError(domain: NSURLErrorDomain,
                       code: NSURLErrorCancelled,
                       userInfo: [NSLocalizedDescriptionKey : description])
    }

    var noResponseError: Error {
        return SessionService.error("Could not create HttpResponse from received response", code: -6)
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
                let error = error ?? SessionService.error("Session invalidated", code: -5)
                self.activeTasks.forEach { $0.performCompletion(error: error) }
                self.sessionQueue.sync { [weak self] in
                    self?.activeTasks.removeAll()
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
                guard let activeTask = self?.activeTasks.last(where: { $0 == task }) else {
                    return
                }
                activeTask.performProgress(completed: totalBytesSent, total: totalBytesExpectedToSend)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didCompleteWithError
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionTask, error: Error?) in
                guard let activeTask = self?.activeTasks.last(where: { $0 == task }) else {
                    return
                }
                if let taskResponse = task.response {
                    activeTask.update(with: taskResponse)
                }
                activeTask.performCompletion(error: error) { [weak self] in
                    self?.sessionQueue.sync { [weak self] in
                        self?.activeTasks.removeAll(where: { $0 == task || $0.status == .finished })
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionDataDelegate() {
        urlSession.rx.didReceiveResponse
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionDataTask, response: URLResponse, completion: (URLSession.ResponseDisposition) -> Void) in
                guard let activeTask = self?.activeTasks.last(where: { $0 == task }) else {
                    completion(.cancel)
                    return
                }
                activeTask.update(with: response)
                completion(.allow)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didReceiveData
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionDataTask, response: Data) in
                guard let activeTask = self?.activeTasks.last(where: { $0 == task }) else {
                    return
                }
                activeTask.update(with: response)
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionDownloadDelegate() {
        urlSession.rx.didFinishDownloading
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionDownloadTask, location: URL) in
                guard let activeTask = self?.activeTasks.last(where: { $0 == task }) else {
                    return
                }
                activeTask.update(with: location)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didWriteData
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] (task: URLSessionDownloadTask, bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) in
            guard let activeTask = self?.activeTasks.last(where: { $0 == task }) else {
                return
            }
            activeTask.performProgress(completed: totalBytesWritten, total: totalBytesExpectedToWrite)
            })
            .disposed(by: disposeBag)
    }
}
