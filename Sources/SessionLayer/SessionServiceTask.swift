//
//  SessionServiceTask.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 09/10/2019.
//

import Foundation

extension SessionService.Task {
    enum Status {
        case suspended
        case running
        case finishing
        case finished
    }
}

extension SessionService {
    final class Task {

        private let task: URLSessionTask
        private var response: HttpResponse?
        private var completionHandlers = [SessionService.CompletionHandler]()
        private let statusQueue = concurrentQueue("statusQueue")

        private(set) var status: Status = .suspended

        ///A representation of the overall task progress.
        var progress: Progress {
            return task.progress
        }

        init(task: URLSessionTask, completion: @escaping SessionService.CompletionHandler) {
            self.task = task
            self.append(completion)
        }

        deinit {
            status = .finishing
            completionHandlers.removeAll()
            status = .finished
        }
    }
}

extension SessionService.Task {

    ///The original request object passed when the task was created.
    var request: URLRequest? {
        return task.originalRequest
    }

    ///Resumes the task, if it is suspended.
    func resume() {
        statusQueue.async(qos: .userInteractive, flags: .barrier) { [weak self] in
            guard let `self` = self, self.status == .suspended else {
                return
            }
            self.status = .running
            self.task.resume()
        }
    }

    ///Temporarily suspends a task.
    func suspend() {
        statusQueue.async(qos: .userInteractive, flags: .barrier) { [weak self] in
            guard let `self` = self, self.status == .running else {
                return
            }
            self.status = .suspended
            self.task.suspend()
        }
    }

    ///Cancels the task.
    func cancel(completion: (() -> Void)? = nil) {
        statusQueue.async(qos: .userInteractive, flags: .barrier) { [weak self] in
            guard let `self` = self, self.status != .finishing && self.status != .finished else {
                return
            }
            self.task.cancel()
            DispatchQueue.global(qos: .utility).async {
                self.performCompletion(error: self.cancelationError, completion: completion)
            }
        }
    }
}

extension SessionService.Task {

    func append(_ completion: @escaping SessionService.CompletionHandler) {
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

    func performProgress(completed: Int64, total: Int64) { }

    func performCompletion(error: Error? = nil, completion: (() -> Void)? = nil) {
        statusQueue.async(qos: .userInteractive, flags: .barrier) { [weak self] in
            guard let `self` = self, self.status != .finishing && self.status != .finished else {
                return
            }
            self.status = .finishing
            let completionError = (error == nil && self.response == nil) ? self.noResponseError : error
            DispatchQueue.global(qos: .utility).async {
                self.completionHandlers.forEach { $0(self.response, completionError) }
                self.completionHandlers.removeAll()
                self.statusQueue.async(qos: .userInteractive, flags: .barrier) { [weak self] in
                    self?.status = .finished
                    DispatchQueue.global(qos: .utility).async {
                        completion?()
                    }
                }
            }
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
