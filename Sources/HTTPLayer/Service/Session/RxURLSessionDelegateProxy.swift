//
//  RxURLSessionDelegateProxy.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 28.06.2019.
//

import RxSwift
import RxCocoa

class RxURLSessionDelegateProxy: DelegateProxy<RxURLSession, RxURLSessionDelegate> {

    fileprivate let downloadSubject = PublishSubject<(session: URLSession, task: URLSessionDownloadTask, location: URL)>()
    private(set) weak var urlSession: RxURLSession?

    init(urlSession: ParentObject) {
        self.urlSession = urlSession
        super.init(parentObject: urlSession, delegateProxy: RxURLSessionDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        register { RxURLSessionDelegateProxy(urlSession: $0) }
    }

    deinit {
        downloadSubject.on(.completed)
    }
}

extension RxURLSessionDelegateProxy: DelegateProxyType {}

extension RxURLSessionDelegateProxy: RxURLSessionDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        downloadSubject.on(.next((session, downloadTask, location)))
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

    //MARK: URLSessionDelegate
    var didBecomeInvalidWithError: Observable<(session: URLSession, error: Error?)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:didBecomeInvalidWithError:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as? Error)
        }
    }

    //MARK: URLSessionTaskDelegate
    var didSendBodyData: Observable<(session: URLSession, task: URLSessionTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionTask,
                    parameters[2] as! Int64,
                    parameters[3] as! Int64,
                    parameters[4] as! Int64)
        }
    }

    var didCompleteWithError: Observable<(session: URLSession, task: URLSessionTask, error: Error?)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:task:didCompleteWithError:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionTask,
                    parameters[2] as? Error)
        }
    }

    //MARK: URLSessionDataDelegate
    private typealias DataTaskResponseHandler = @convention(block) (URLSession.ResponseDisposition) -> Void
    
    var didReceiveResponse: Observable<(session: URLSession, task: URLSessionDataTask, response: URLResponse, completion: (URLSession.ResponseDisposition) -> Void)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:dataTask:didReceive:completionHandler:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionDataTask,
                    parameters[2] as! URLResponse,
                    unsafeBitCast(parameters[3] as AnyObject, to: DataTaskResponseHandler.self))
        }
    }

    var didReceiveData: Observable<(session: URLSession, task: URLSessionDataTask, response: Data)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:dataTask:didReceive:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionDataTask,
                    parameters[2] as! Data)
        }
    }

    //MARK: URLSessionDownloadDelegate
    var didFinishDownloading: Observable<(session: URLSession, task: URLSessionDownloadTask, location: URL)> {
        return delegateProxy.downloadSubject
    }

    var didWriteData: Observable<(session: URLSession, task: URLSessionDownloadTask, bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)> {
        return delegate.methodInvoked(#selector(RxURLSessionDelegate.urlSession(_:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:))).map { parameters in
            return (parameters[0] as! URLSession,
                    parameters[1] as! URLSessionDownloadTask,
                    parameters[2] as! Int64,
                    parameters[3] as! Int64,
                    parameters[4] as! Int64)
        }
    }
}
