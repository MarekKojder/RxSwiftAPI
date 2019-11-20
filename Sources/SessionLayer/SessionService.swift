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

final class SessionService: QueueRelated {

    typealias ProgressHandler = (_ progress: Progress) -> ()
    typealias CompletionHandler = (_ response: Http.Response?, _ error: Error?) -> ()

    private(set) var status = Status.valid

    private let urlSession: RxURLSession
    private let configuration: Http.Service.Configuration
    private let sessionQueue = serialQueue("sessionQueue")
    private let serialScheduler: SerialDispatchQueueScheduler
    private let concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: concurrentQueue("concurrentScheduler"))
    private let disposeBag = DisposeBag()
    private var activeTasks = [Task]()
    private var backgroundSessionCompletionHandler: (() -> Void)?
    private weak var fileManager: FileManager?

    init(configuration: Http.Service.Configuration, fileManager: FileManager) {
        self.configuration = configuration
        self.fileManager = fileManager
        urlSession = RxURLSession(configuration: configuration.urlSessionConfiguration)
        serialScheduler = SerialDispatchQueueScheduler(queue: sessionQueue, internalSerialQueueName: Self.queue("serialScheduler"))
        
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

    //The background session identifier of the configuration.
    var identifier: String? {
        return configuration.urlSessionConfiguration.identifier
    }

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - completion: Block for hangling request completion.

     - Returns: Task object which allows to follow progress and manage request.

     - Throws: Error when Task could not be created.
     */
    func data(request: URLRequest, completion: @escaping CompletionHandler) throws -> Task {
        return try safely(add: completion) { [weak self] in
            return (self?.urlSession.dataTask(with: request), nil)
        }
    }

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - completion: Block for hangling request completion.

     - Returns: Task object which allows to follow progress and manage request.

     - Throws: Error when Task could not be created.
     */
    func upload(request: URLRequest, file: URL, completion: @escaping CompletionHandler) throws -> Task {
           return try safely(add: completion) { [weak self] in
            return (self?.urlSession.uploadTask(with: request, fromFile: file), nil)
        }
    }

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - completion: Block for hangling request completion.

     - Returns: Task object which allows to follow progress and manage request.

     - Throws: Error when Task could not be created.
     */
    func download(request: URLRequest, fileDestination: URL, completion: @escaping CompletionHandler) throws -> Task  {
           return try safely(add: completion) { [weak self] in
            return (self?.urlSession.downloadTask(with: request), fileDestination)
        }
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

    /**
     Handle events for background session.

     - Parameters:
       - completion: The completion handler to call when you finish processing the events.
     */
    func handleBackgroundEvents(with completion: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completion
    }
}

extension SessionService: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(urlSession.configuration)
    }

    static func ==(lhs: SessionService, rhs: SessionService) -> Bool {
        return lhs.urlSession.configuration == rhs.urlSession.configuration
    }

    static func ==(lhs: SessionService, rhs: Http.Service.Configuration) -> Bool {
        return lhs.configuration == rhs
    }
}

private extension SessionService {

    ///Domain of RxSwiftAPI errors.
    private static let sessionDomain = "RxSwiftAPI.SessionService.ErrorDomain"

    static func error(_ description: String, code: Int) -> Error {
        return NSError(domain: sessionDomain, code: code, userInfo: [NSLocalizedDescriptionKey : description])
    }

    func safely(add completion: @escaping CompletionHandler, and createTask: @escaping () -> (session: URLSessionTask?, fileDestination: URL?)) throws -> Task {
        try sessionQueue.sync { [weak self] in
            guard let `self` = self else {
                throw SessionService.error("Lost reference to SessionService.", code: -1)
            }
            guard self.status == .valid else {
                throw  SessionService.error("Attempted to create URLSessionTask in a session that has been invalidated.", code: -2)
            }
            let created = createTask()
            guard let urlSessionTask = created.session else {
                throw SessionService.error("URLSessionTask could not be created.", code: -3)
            }
            let task = Task(task: urlSessionTask, fileDestination: created.fileDestination, completion: completion)
            self.activeTasks.append(task)
            return task
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
                let group = DispatchGroup()
                self.activeTasks.forEach { task in
                    group.enter()
                    task.performCompletion(error: error) {
                        group.leave()
                    }
                }
                group.notify(queue: self.sessionQueue) { [weak self] in
                    self?.activeTasks.removeAll()
                    self?.status = .invalidated
                }
            })
            .disposed(by: disposeBag)

        #if !os(OSX)
        urlSession.rx.didFinishEventsForBackgroundSession
            .asObservable()
            .subscribeOn(concurrentScheduler)
            .observeOn(serialScheduler)
            .subscribe(onNext: { [weak self] in
                DispatchQueue.main.async {
                    guard let completion = self?.backgroundSessionCompletionHandler else {
                        return
                    }
                    self?.backgroundSessionCompletionHandler = nil
                    completion()
                }
            })
            .disposed(by: disposeBag)
        #endif

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
            //We should observeOn the same queue which delegate calls, because temporary file will be lost
            .subscribe(onNext: { [weak self] (task: URLSessionDownloadTask, location: URL) in
                guard let activeTask = self?.activeTasks.last(where: { $0 == task }) else {
                    return
                }
                if let destination = activeTask.fileDestinationUrl, let fileManager = self?.fileManager {
                    if let error = fileManager.copyFile(from: location, to: destination) {
                        activeTask.update(with: error)
                    } else {
                        activeTask.update(with: destination)
                    }
                } else {
                    activeTask.update(with: SessionService.error("Could nod copy file from temporary location.", code: -7))
                }
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
