//
//  SessionServiceTask.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 09/10/2019.
//

import Foundation

extension SessionService.Task {
    enum Status {
        case suspend
        case running
        case finishing
        case finished
    }
}

extension SessionService {
    final class Task {

        private(set) var status: Status = .suspend

        private let task: URLSessionTask
        private var response: HttpResponse?
        private var progressHandlers = [SessionService.ProgressHandler]()
        private var completionHandlers = [SessionService.CompletionHandler]()

        init(task: URLSessionTask, progress: SessionService.ProgressHandler?, completion: @escaping SessionService.CompletionHandler) {
            self.task = task
            if let progress = progress {
                progressHandlers.append(progress)
            }
            completionHandlers.append(completion)
        }

        deinit {
            status = .finishing
            progressHandlers.removeAll()
            completionHandlers.removeAll()
            status = .finished
        }
    }
}
extension SessionService.Task {

    var request: URLRequest? {
        return task.originalRequest
    }

    func resume() {
        status = .running
        task.resume()
    }

    func suspend() {
        status = .suspend
        task.suspend()
    }

    func cancel(completion: (() -> Void)? = nil) {
        task.cancel()
        performCompletion(error: cancelationError, completion: completion)
    }
}

extension SessionService.Task {

    func append(progress: SessionService.ProgressHandler?, completion: @escaping SessionService.CompletionHandler) {
        if let progress = progress {
            progressHandlers.append(progress)
        }
        completionHandlers.append(completion)
    }

    func update(with urlResponse: URLResponse) {
        if response == nil {
            response = HttpResponse(urlResponse: urlResponse)
        } else {
            response?.update(with: urlResponse)
        }
    }

    func update(with data: Data) {
        if response == nil {
            response = HttpResponse(body: data)
        } else {
            response?.appendBody(data)
        }
    }

    func update(with resourceUrl: URL) {
        if response == nil {
            response = HttpResponse(resourceUrl: resourceUrl)
        } else {
            response?.update(with: resourceUrl)
        }
    }

    func performProgress(completed: Int64, total: Int64) {
        progressHandlers.forEach { $0(task.progress) }
    }

    func performCompletion(error: Error? = nil, completion: (() -> Void)? = nil) {
        guard status != .finishing && status != .finished else {
            return
        }
        status = .finishing
        let completionError = (error == nil && response == nil) ? noResponseError : error
        DispatchQueue.global(qos: .utility).async {
            self.completionHandlers.forEach { $0(self.response, completionError) }
            self.completionHandlers.removeAll()
            self.progressHandlers.removeAll()
            self.status = .finished
            completion?()
        }
    }
}

extension SessionService.Task: Equatable {
    static func == (lhs: SessionService.Task, rhs: SessionService.Task) -> Bool {
        return lhs.task == rhs.task
    }

    static func == (lhs: SessionService.Task, rhs: URLSessionTask) -> Bool {
        return lhs.task == rhs
    }
}

extension SessionService.Task: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(task)
    }
}
