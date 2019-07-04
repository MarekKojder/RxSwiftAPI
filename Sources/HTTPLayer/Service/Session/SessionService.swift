//
//  SessionService.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 07.03.2018.
//

import RxSwift

final class SessionService {

    private let urlSession: RxURLSession
    private let serialScheduler = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "RxSwiftAPI.SessionService.observationQueue")
    private let concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "RxSwiftAPI.SessionService.subscriptionQueue", qos: .utility))
    private let disposeBag = DisposeBag()
    private var activeCalls = [URLSessionTask: HttpCall]()
    private(set) var isValid = true

    init(configuration: RequestService.Configuration) {
        urlSession = RxURLSession(configuration: configuration.urlSessionConfiguration)
        setupURLSessionDelegate()
        setupURLSessionTaskDelegate()
        setupURLSessionDataDelegate()
        setupURLSessionDownloadDelegate()
    }

    deinit {
        urlSession.invalidateAndCancel()
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
        safely(add: HttpCall(progress: progress, completion: completion), and: { [unowned self] in
            return self.urlSession.dataTask(with: request)
        })
            .subscribeOn(serialScheduler)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe(onSuccess: { task in
                task.resume()
            }, onError: { error in
                completion(nil, error)
            }).disposed(by: disposeBag)
    }

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - progress: Block for hangling request progress.
       - completion: Block for hangling request completion.
     */
    func upload(request: URLRequest, file: URL, progress: @escaping SessionServiceProgressHandler, completion: @escaping SessionServiceCompletionHandler) {
        safely(add: HttpCall(progress: progress, completion: completion), and: { [unowned self] in
            return self.urlSession.uploadTask(with: request, fromFile: file)
        })
            .subscribeOn(serialScheduler)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe(onSuccess: { task in
                task.resume()
            }, onError: { error in
                completion(nil, error)
            }).disposed(by: disposeBag)
    }

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - progress: Block for hangling request progress.
       - completion: Block for hangling request completion.
     */
    func download(request: URLRequest, progress: @escaping SessionServiceProgressHandler, completion: @escaping SessionServiceCompletionHandler) {
        safely(add: HttpCall(progress: progress, completion: completion), and: { [unowned self] in
            return self.urlSession.downloadTask(with: request)
        })
            .subscribeOn(serialScheduler)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe(onSuccess: { task in
                task.resume()
            }, onError: { error in
                completion(nil, error)
            }).disposed(by: disposeBag)
    }

    /**
     Temporarily suspends given HTTP request.

     - Parameter request: An URLRequest to suspend.
     */
    func suspend(_ request: URLRequest) {
        Completable.create(subscribe: { [weak self] completable in
            self?.activeCalls.forEach { (task, _) in
                guard task.currentRequest == request else { return }
                task.suspend()
            }
            completable(.completed)
            return Disposables.create()
        })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe()
            .disposed(by: disposeBag)
    }

    /**
     Resumes given HTTP request, if it is suspended.

     - Parameter request: An URLRequest to resume.
     */
    @available(iOS 9.0, OSX 10.11, *)
    func resume(_ request: URLRequest) {
        Completable.create(subscribe: { [weak self] completable in
            self?.activeCalls.forEach { (task, _) in
                guard task.currentRequest == request else { return }
                task.resume()
            }
            completable(.completed)
            return Disposables.create()
        })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe()
            .disposed(by: disposeBag)
    }

    /**
     Cancels given HTTP request.

     - Parameter request: An URLRequest to cancel.
     */
    func cancel(_ request: URLRequest) {
        Completable.create(subscribe: { [weak self] completable in
            self?.activeCalls.forEach { (task, _) in
                guard task.currentRequest == request else { return }
                task.cancel()
            }
            completable(.completed)
            return Disposables.create()
        })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe()
            .disposed(by: disposeBag)


    }

    ///Cancels all currently running HTTP requests.
    func cancelAllRequests() {
        Completable.create(subscribe: { [weak self] completable in
            self?.activeCalls.forEach { $0.key.cancel() }
            completable(.completed)
            return Disposables.create()
        })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .subscribe()
            .disposed(by: disposeBag)

    }

    ///Cancels all currently running HTTP requests and invalidates session.
    func invalidateAndCancel() {
        Completable.create(subscribe: { [weak self] completable in
            self?.isValid = false
            self?.urlSession.invalidateAndCancel()
            completable(.completed)
            return Disposables.create()
        })
            .subscribeOn(serialScheduler)
            .subscribe()
            .disposed(by: disposeBag)
    }
}

private extension SessionService {

    static func error(_ description: String) -> Error {
        return NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: [NSLocalizedDescriptionKey : description])
    }

    func safely(add httpCall: HttpCall, and createTask: @escaping () -> URLSessionTask?) -> Single<URLSessionTask> {
        return Single.create { [weak self] single in
            guard let `self` = self else {
                single(.error(SessionService.error("Lost reference to SessionService.")))
                return Disposables.create()
            }
            guard self.isValid else {
                single(.error(SessionService.error("Attempted to create URLSessionTask in a session that has been invalidated.")))
                return Disposables.create()
            }
            guard let task = createTask() else {
                single(.error(SessionService.error("URLSessionTask could not be created.")))
                return Disposables.create()
            }
            if let call = self.activeCalls[task], !call.isFinished {
                single(.error(SessionService.error("Attempted to add URLSessionTask which is already running.")))
                return Disposables.create()
            }

            self.activeCalls[task] = httpCall
            single(.success(task))

            return Disposables.create {
                task.cancel()
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
                guard let call = self?.activeCalls[task] else {
                    return
                }
                guard let taskResponse = task.response else {
                    call.performCompletion(response: nil, error: error)
                    return
                }
                call.update(with: taskResponse)
                guard let response = call.response else {
                    call.performCompletion(response: nil, error: error)
                    return
                }
                call.performCompletion(response: response, error: nil)
                self?.activeCalls.removeValue(forKey: task)
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
