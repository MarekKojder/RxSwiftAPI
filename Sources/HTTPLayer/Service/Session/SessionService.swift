//
//  SessionService.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 07.03.2018.
//

import RxSwift

final class SessionService {

    let urlSession: RxURLSession
    let observationQueue = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "RxSwiftAPI.SessionService.observationQueue")
    let subscriptionQueue = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "RxSwiftAPI.SessionService.subscriptionQueue", qos: .utility))
    
    private let disposeBag = DisposeBag()



    private(set) var isValid = true
    private let sessionQueue = DispatchQueue(label: "RxSwiftAPI.SessionService.sessionQueue", qos: .background)
    private var activeCalls = [URLSessionTask: HttpCall]()

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
       - success: Block for hangling request success.
       - failure: Block for hangling request failure.
     */
    func data(request: URLRequest, progress: @escaping SessionServiceProgressHandler, success: @escaping SessionServiceSuccessHandler, failure: @escaping SessionServiceFailureHandler) {
        performInSesionQueue(failure: failure) { [unowned self] in
            let task = self.urlSession.dataTask(with: request)
            self.activeCalls[task] = HttpCall(progressBlock: progress, successBlock: success, failureBlock: failure)
            DispatchQueue.global().async {
                task.resume()
            }
        }
    }

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - progress: Block for hangling request progress.
       - success: Block for hangling request success.
       - failure: Block for hangling request failure.
     */
    func upload(request: URLRequest, file: URL, progress: @escaping SessionServiceProgressHandler, success: @escaping SessionServiceSuccessHandler, failure: @escaping SessionServiceFailureHandler) {
        performInSesionQueue(failure: failure) { [unowned self] in
            let task = self.urlSession.uploadTask(with: request, fromFile: file)
            self.activeCalls[task] = HttpCall(progressBlock: progress, successBlock: success, failureBlock: failure)
            DispatchQueue.global().async {
                task.resume()
            }
        }
    }

    /**
     Sends given URLRequest.

     - Parameters:
       - request: An URLRequest object to send in download task.
       - progress: Block for hangling request progress.
       - success: Block for hangling request success.
       - failure: Block for hangling request failure.
     */
    func download(request: URLRequest, progress: @escaping SessionServiceProgressHandler, success: @escaping SessionServiceSuccessHandler, failure: @escaping SessionServiceFailureHandler) {
        performInSesionQueue(failure: failure) { [unowned self] in
            let task = self.urlSession.downloadTask(with: request)
            self.activeCalls[task] = HttpCall(progressBlock: progress, successBlock: success, failureBlock: failure)
            DispatchQueue.global().async {
                task.resume()
            }
        }
    }

    ///Validates self and performs given block in session queue.
    private func performInSesionQueue(failure: @escaping SessionServiceFailureHandler, block: () -> Void) {
        sessionQueue.sync { [weak self] in
            guard let strongSelf = self else {
                let description = "Attempted to create task in a session that has been invalidated."
                failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: [NSLocalizedDescriptionKey : description]))
                return
            }
            guard strongSelf.isValid else {
                let description = "Lost reference to self."
                failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: [NSLocalizedDescriptionKey : description]))
                return
            }
            block()
        }
    }

    /**
     Temporarily suspends given HTTP request.

     - Parameter request: An URLRequest to suspend.
     */
    func suspend(_ request: URLRequest) {
        activeCalls.forEach { (task, _) in
            guard task.currentRequest == request else { return }
            task.suspend()
        }
    }

    /**
     Resumes given HTTP request, if it is suspended.

     - Parameter request: An URLRequest to resume.
     */
    @available(iOS 9.0, OSX 10.11, *)
    func resume(_ request: URLRequest) {
        activeCalls.forEach { (task, _) in
            guard task.currentRequest == request else { return }
            task.resume()
        }
    }

    /**
     Cancels given HTTP request.

     - Parameter request: An URLRequest to cancel.
     */
    func cancel(_ request: URLRequest) {
        activeCalls.forEach { (task, _) in
            guard task.currentRequest == request else { return }
            task.cancel()
        }
    }

    ///Cancels all currently running HTTP requests.
    func cancelAllRequests() {
        activeCalls.forEach { $0.key.cancel() }
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

    func setupURLSessionDelegate() {
        urlSession.rx.didBecomeInvalidWithError
            .asObservable()
            .subscribeOn(subscriptionQueue)
            .observeOn(observationQueue)
            .subscribe(onNext: { [weak self] (session: URLSession, error: Error?) in
                self?.isValid = false
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionTaskDelegate() {
        urlSession.rx.didSendBodyData
            .asObservable()
            .subscribeOn(subscriptionQueue)
            .observeOn(observationQueue)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
                self?.activeCalls[task]?.performProgress(totalBytesProcessed: totalBytesSent, totalBytesExpectedToProcess: totalBytesExpectedToSend)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didCompleteWithError
            .asObservable()
            .subscribeOn(subscriptionQueue)
            .observeOn(observationQueue).subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionTask, error: Error?) in
                guard let call = self?.activeCalls[task] else {
                    return
                }
                guard let taskResponse = task.response else {
                    call.performFailure(with: error)
                    return
                }
                call.update(with: taskResponse)
                guard let response = call.response else {
                    call.performFailure(with: error)
                    return
                }
                call.performSuccess(with: response)
                self?.activeCalls.removeValue(forKey: task)
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionDataDelegate() {
        urlSession.rx.didReceiveResponse
            .asObservable()
            .subscribeOn(subscriptionQueue)
            .observeOn(observationQueue)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionDataTask, response: URLResponse, completion: (URLSession.ResponseDisposition) -> Void) in
                self?.activeCalls[task]?.update(with: response)
                self?.activeCalls[task] != nil ? completion(.allow) : completion(.cancel)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didReceiveData
            .asObservable()
            .subscribeOn(subscriptionQueue)
            .observeOn(observationQueue)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionDataTask, response: Data) in
                self?.activeCalls[task]?.update(with: response)
            })
            .disposed(by: disposeBag)
    }

    func setupURLSessionDownloadDelegate() {
        urlSession.rx.didFinishDownloading
            .asObservable()
            .subscribeOn(subscriptionQueue)
            .observeOn(observationQueue)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionDownloadTask, location: URL) in
                self?.activeCalls[task]?.update(with: location)
            })
            .disposed(by: disposeBag)

        urlSession.rx.didWriteData
            .asObservable()
            .subscribeOn(subscriptionQueue)
            .observeOn(observationQueue)
            .subscribe(onNext: { [weak self] (session: URLSession, task: URLSessionDownloadTask, bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) in
                self?.activeCalls[task]?.performProgress(totalBytesProcessed: totalBytesWritten, totalBytesExpectedToProcess: totalBytesExpectedToWrite)
            })
            .disposed(by: disposeBag)
    }
}
