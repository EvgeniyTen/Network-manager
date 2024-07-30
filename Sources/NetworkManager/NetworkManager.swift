import Foundation
import Combine

public final class NetworkService: NSObject, NetworkServiceProtocol {
    private let baseURL: String
    private let session: URLSession
    private let refresh: Network.Refresh?
    private var refeshTask: Task<Void, Error>?
    /**
     This class requests data via UrlSession
     - parameter baseURL: base url, must соntain protocol and host; can contain path
     - parameter session: pre-configured urlSession to use with all requests
     */
    public init(baseURL: String,
                session: URLSession = URLSession.default(),
                refresh: Network.Refresh? = nil) {
        self.baseURL = baseURL
        self.session = session
        self.refresh = refresh
    }

    // MARK: NetworkServiceProtocol

    public func build(
        path: String,
        method: Network.HTTPMethod
    ) throws -> BodyableRequestBuilderProtocol {
        try Network.BodyableRequestBuilder(client: self,
                                   baseURL: baseURL,
                                   method: method,
                                   path: path)
    }

    public func build(
        path: String,
        fileURL: URL,
        method: Network.MultipartHTTPMethod = .post
    ) throws -> RequestBuilderProtocol {
        try Network.RequestBuilder(client: self,
                                   baseURL: baseURL,
                                   method: method,
                                   fileURL: fileURL,
                                   path: path
        )
    }

    public func request(request: URLRequest, withRefresh: Bool) async throws -> Data {
        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw Network.Error.emptyResponseData
        }

        switch response.statusCode {
        case Network.Status.success.value:
            return data
        case refresh?.status.value where refresh?.status.value != nil && withRefresh == true:
            if refeshTask == nil {
                refeshTask = Task {
                    try await refresh?.action()
                    refeshTask = nil
                }
            }
            // swiftlint: disable force_unwrapping
            try await refeshTask!.value
            // swiftlint: enable force_unwrapping
            return try await self.request(request: request, withRefresh: false)
        default:
            throw Network.Error.serverStatusData(
                status: Network.Status(rawValue: response.statusCode),
                errorData: data)
        }
    }

    public func request<R>(request: URLRequest,
                           withRefresh: Bool,
                           decoder: DataDecoderProtocol) async throws -> R where R: Decodable {
        let data: Data = try await self.request(request: request, withRefresh: withRefresh)
        if R.self == Data.self,
           let data = data as? R {
            return data
        }

        do {
            return try decoder.decode(R.self, from: data)
        } catch let error {
            throw Network.Error.corruptedData(error)
        }
    }
}
