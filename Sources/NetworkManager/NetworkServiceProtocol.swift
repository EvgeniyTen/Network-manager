import Foundation
import Combine

public protocol NetworkServiceProtocol: NSObjectProtocol {
    /**
     This method creates request builder
     - parameter path: path relative to baseURL
     - parameter method: request method
     - returns: request builder
     - throws : Network.Error
     
     # Example #
     ```
     let builder = try self.build("path/to/", .get)
     ```
     */
    func build(
        path: String,
        method: Network.HTTPMethod
    ) throws -> BodyableRequestBuilderProtocol

    /**
     This method creates request builder
     - parameter path: path relative to baseURL
     - parameter fileURL: path to user data
     - parameter method: only POST
     - returns: request builder
     - throws : Network.Error
     
     # Example #
     ```
     let builder = try self.build("path/to/", fileURL: URL)
     ```
     */
    func build(
        path: String,
        fileURL: URL,
        method: Network.MultipartHTTPMethod
    ) throws -> RequestBuilderProtocol
    /**
     This method requests data via Network
     - parameter request: url request
     - returns: Data retrived via request
     - throws : Network.Error
     
     # Example #
     ```
     let responce = try await self.request(
     request: URLRequest(url: "https://test.ru/path")
     )
     ```
     */
    @discardableResult
    func request(request: URLRequest, withRefresh: Bool) async throws -> Data

    /**
     This method requests data via Network
     - parameter request: url request
     - parameter decoder: responce body decoder
     - returns: Data retrived via request, decoded via decoder
     - throws : Network.Error
     
     # Example #
     ```
     let responce = try await self.request(
     request: URLRequest(url: "https://test.ru/path"),
     decoder: JsonDecoder()
     )
     ```
     **/
    func request<R: Decodable>(request: URLRequest,
                               withRefresh: Bool,
                               decoder: DataDecoderProtocol) async throws -> R
}

public extension NetworkServiceProtocol {
    /**
     This method requests data via Network
     - parameter request: url request
     - parameter decoder: responce body decoder
     - returns: Future, containing decoded response or  Error
     
     # Example #
     ```
     let cancellable = self.future.sink(
     receiveCompletion: { completion in
     switch completion {
     case .failure(let error):
     print("error \(error)")
     case .finished:
     break
     }
     
     expectation.fulfill()
     },
     receiveValue: { value in
     print("success \(value)")
     }
     )
     ```
     **/
    func future<R: Decodable>(request: URLRequest,
                              withRefresh: Bool,
                              decoder: DataDecoderProtocol) -> Future<R, Error> {
        Future {
            try await self.request(request: request, withRefresh: withRefresh, decoder: decoder)
        }
    }
}

public extension NetworkServiceProtocol {
    @discardableResult
    func request(request: URLRequest) async throws -> Data {
        try await self.request(request: request, withRefresh: false)
    }

    func request<R: Decodable>(request: URLRequest,
                               decoder: DataDecoderProtocol) async throws -> R {
        try await self.request(request: request, withRefresh: false, decoder: decoder)
    }
}
