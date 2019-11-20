//
//  HttpDownloadRequest.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 02.01.2017.
//

import Foundation

extension Http {

    final class DownloadRequest: Request {

        /**
         Destination URL for downloading resource.

         - Important: If any file exists at *destinationUrl* it will be overridden by downloaded file.
         */
        let destinationUrl: URL

        ///Method not allowed to use in current class.
        @available(*, unavailable)
        private override init(url: URL, method: Method, headers: [Header]? = nil) {
            self.destinationUrl = URL(fileURLWithPath: "")
            super.init(url: url, method: method)
        }

        /**
         Creates and initializes a HttpDownloadRequest with the given parameters.

         - Parameters:
           - url: URL of the receiver.
           - destinationUrl: destination URL for downloading resource.
           - onSuccess: action which needs to be performed when response was received from server.
           - onFailure: action which needs to be performed, when request has failed.
           - useProgress: flag indicates if Progress object should be created.

         - Returns: An initialized a HttpDownloadRequest object.
         */
        init(url: URL, destinationUrl: URL, headers: [Header]? = nil) {
            self.destinationUrl = destinationUrl
            super.init(url: url, method: .get, headers: headers)
        }
    }
}
