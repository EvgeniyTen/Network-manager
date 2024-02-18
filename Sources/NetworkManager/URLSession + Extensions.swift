import Foundation

public extension URLSession {
    static func `default`() -> URLSession {
        URLSession(configuration: URLSessionConfiguration.default)
    }

    static func noCookies() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 600
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never

        return URLSession(configuration: configuration)
    }
}
