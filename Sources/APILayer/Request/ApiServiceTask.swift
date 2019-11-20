//
//  ApiServiceTask.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 11/10/2019.
//

import Foundation

public extension Api.Service.Task {

    /**
     Task Status

     - suspended: task is not running yer or is paused,
     - running: task is during execution,
     - finished: task has finished.
    */
    enum Status {
        case suspended
        case running
        case finished
    }
}

public extension Api.Service {

    ///Class which allows to manage request and follow its progress.
    final class Task {
        private let task: SessionService.Task

        ///Current Status of task
        public var status: Status {
            switch task.status {
            case .suspended:
                return .suspended
            case .running:
                return .running
            case .finishing,
                 .finished:
                return .finished
            }
        }

        ///A representation of the overall task progress.
        public var progress: Progress {
            return task.progress
        }

        internal init(_ task: SessionService.Task) {
            self.task = task
        }
    }
}

public extension Api.Service.Task {

    ///Resumes the task, if it is suspended.
    func resume() {
        task.resume()
    }

    ///Temporarily suspends a task.
    func suspend() {
        task.suspend()
    }

    ///Cancels the task.
    func cancel() {
        task.cancel()
    }
}

extension Api.Service.Task: Equatable {

    public static func == (lhs: Api.Service.Task, rhs: Api.Service.Task) -> Bool {
        return lhs.task == rhs.task
    }
}

extension Api.Service.Task: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(task)
    }
}
