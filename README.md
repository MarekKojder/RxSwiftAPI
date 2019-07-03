# RxSwiftAPI

<div align = "center">
  <a href="http://cocoapods.org/pods/RxSwiftAPI">
    <img src="https://img.shields.io/cocoapods/v/RxSwiftAPI.svg?style=flat" />
  </a>
</div>
<div align = "center">
  <a href="http://cocoapods.org/pods/RxSwiftAPI" target="blank">
    <img src="https://img.shields.io/cocoapods/p/RxSwiftAPI.svg?style=flat" />
  </a>
  <a href="http://cocoapods.org/pods/RxSwiftAPI">
    <img src="https://img.shields.io/badge/swift-5.0-brightgreen.svg" />
  </a>
  <a href="http://cocoapods.org/pods/RxSwiftAPI" target="blank">
    <img src="https://img.shields.io/cocoapods/l/RxSwiftAPI.svg?style=flat" />
  </a>
  <br>
  <br>
</div>

**RxSwiftAPI** was born as idea of having very light, very fast, easy to use written in Swift and reactive library for communication through network.
Main features of library:
- Written in Swift 5
- Ready to use out of the box
- Uses `URLSession` for managing requests
- Allows sending requests in foreground or background
- Supports connection with REST and non-REST APIs
- Is available for iOS, macOS, watchOS and tvOS
- Supports `Codable` protocol
- Based on [SwiftAPI](https://cocoapods.org/pods/SwiftAPI) and uses `RxSwift` 5


## Installation

RxSwiftAPI is available through [CocoaPods](https://cocoapods.org/pods/RxSwiftAPI). To install it, simply add the following line to your Podfile
```ruby
pod 'RxSwiftAPI'
```
and run
```ruby
pod install
```


## Usage

At the beginning, import library by adding
```swift
import RxSwiftAPI
```
then you can create instance of ApiService
```swift
let apiService = ApiService()
```
or RestService
```swift
let rootURL = URL(string:"https://API.SERVER.ADDRESS.COM")
let apiPath = "/v1.0"
let restService = RestService(baseUrl: rootURL, apiPath: apiPath)
```
and now you can start sending requests.

To get familiar with more advanced usage please take a look at usage example available with library.


## Authors

- [Marek Kojder](https://github.com/MarekKojder)


## License

RxSwiftAPI is available under the MIT license. See the LICENSE file for more info.

## Note

RxSwiftAPI is not fully converted to reactive version yet. Please, be patient, work is in progress :-).
