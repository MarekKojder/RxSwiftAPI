//
//  RxURLSessionDelegateProxy.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 28.06.2019.
//

import RxSwift
import RxCocoa

class RxURLSessionDelegateProxy: DelegateProxy<RxURLSession, RxURLSessionDelegate> {

    private weak var urlSession: RxURLSession?
    fileprivate let downloadSubject = PublishSubject<(task: URLSessionDownloadTask, location: URL)>()

    init(urlSession: ParentObject) {
        self.urlSession = urlSession
        super.init(parentObject: urlSession, delegateProxy: RxURLSessionDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        register { RxURLSessionDelegateProxy(urlSession: $0) }
    }

    deinit {
        downloadSubject.on(.completed)
    }
}

extension RxURLSessionDelegateProxy: DelegateProxyType {}

extension RxURLSessionDelegateProxy: RxURLSessionDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        downloadSubject.on(.next((downloadTask, location)))
        _forwardToDelegate?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }
}

extension Reactive where Base: RxURLSession {

    private var delegateProxy: RxURLSessionDelegateProxy {
        return RxURLSessionDelegateProxy.proxy(for: base)
    }

    private var delegate: DelegateProxy<RxURLSession, RxURLSessionDelegate> {
        return delegateProxy
    }

    private func invoked(_ selector: Selector) -> Observable<[Any]> {
        return delegate.methodInvoked(selector)
    }

    //MARK: URLSessionDelegate
    public var didBecomeInvalidWithError: Observable<Error?> {
        return invoked(#selector(RxURLSessionDelegate.urlSession(_:didBecomeInvalidWithError:))).map { parameters in
            return (parameters[1] as? Error)
        }
    }

    @available(macOS, unavailable)
    public var didFinishEventsForBackgroundSession: Observable<Void> {
        return invoked(#selector(RxURLSessionDelegate.urlSessionDidFinishEvents(forBackgroundURLSession:))).map { _ in
            return
        }
    }

    //MARK: URLSessionTaskDelegate
    public var didSendBodyData: Observable<(task: URLSessionTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)> {
        return invoked(#selector(RxURLSessionDelegate.urlSession(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:))).map { parameters in
            return (parameters[1] as! URLSessionTask,
                    parameters[2] as! Int64,
                    parameters[3] as! Int64,
                    parameters[4] as! Int64)
        }
    }

    public var didCompleteWithError: Observable<(task: URLSessionTask, error: Error?)> {
        return invoked(#selector(RxURLSessionDelegate.urlSession(_:task:didCompleteWithError:))).map { parameters in
            return (parameters[1] as! URLSessionTask,
                    parameters[2] as? Error)
        }
    }

    //MARK: URLSessionDataDelegate
    private typealias DataTaskResponseHandler = @convention(block) (URLSession.ResponseDisposition) -> Void

    public var didReceiveResponse: Observable<(task: URLSessionDataTask, response: URLResponse, completion: (URLSession.ResponseDisposition) -> Void)> {
        return invoked(#selector(RxURLSessionDelegate.urlSession(_:dataTask:didReceive:completionHandler:))).map { parameters in
            return (parameters[1] as! URLSessionDataTask,
                    parameters[2] as! URLResponse,
                    unsafeBitCast(parameters[3] as AnyObject, to: DataTaskResponseHandler.self))
        }
    }

    public var didReceiveData: Observable<(task: URLSessionDataTask, response: Data)> {
        return invoked(#selector(RxURLSessionDelegate.urlSession(_:dataTask:didReceive:))).map { parameters in
            return (parameters[1] as! URLSessionDataTask,
                    parameters[2] as! Data)
        }
    }

    //MARK: URLSessionDownloadDelegate
    public var didFinishDownloading: Observable<(task: URLSessionDownloadTask, location: URL)> {
        return delegateProxy.downloadSubject
    }

    public var didWriteData: Observable<(task: URLSessionDownloadTask, bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)> {
        return invoked(#selector(RxURLSessionDelegate.urlSession(_:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:))).map { parameters in
            return (parameters[1] as! URLSessionDownloadTask,
                    parameters[2] as! Int64,
                    parameters[3] as! Int64,
                    parameters[4] as! Int64)
        }
    }
}
