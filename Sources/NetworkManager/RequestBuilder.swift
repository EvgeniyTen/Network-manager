import Foundation
import Combine

@available(iOS 15.0.0, *)
extension Network {
    public class RequestBuilder: RequestBuilderProtocol {
        private let client: NetworkServiceProtocol
        private var request: URLRequest
        private var refresh = false

        public init(client: NetworkServiceProtocol,
                    baseURL: String,
                    method: HTTPMethod,
                    path: String) throws {
            guard let url = URL(string: baseURL),
                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw Network.Error.unableConstructURL
            }
            components.path = Self.createPath(path: components.path, append: path)

            self.client = client

            guard let url = components.url else {
                throw Network.Error.unableCounstructURLWithParameters
            }

            self.request = URLRequest(url: url)
            self.request.httpMethod = method.rawValue
        }

        @discardableResult
        public func queryItems(_ items: [URLQueryItem]) throws -> Self {
            guard let url = request.url,
                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw Network.Error.unableConstructURL
            }

            components.queryItems = items
            guard let url = components.url else {
                throw Network.Error.unableCounstructURLWithParameters
            }

            request.url = url
            return self
        }

        @discardableResult
        public func headers(_ headers: [Network.HTTPHeader: String]) -> Self {
            headers.forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.key.value)
            }
            return self
        }

        @discardableResult
        public func body(_ body: Encodable,
                         encoder: DataEncoderProtocol = JSONEncoder()) throws -> Self {
            guard request.httpMethod != Network.HTTPMethod.get.rawValue else {
                throw Network.Error.unableAddBody
            }

            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw Network.Error.unableEncodeBody(error)
            }
            return self
        }

        @discardableResult
        public func withRefresh() -> Self {
            self.refresh = true
            return self
        }

        private static func createPath(path: String, append: String) -> String {
            let path = path.last == "/" ? String(path.prefix(path.count - 1)) : path
            let append = append.first == "/" ? String(append.suffix(append.count - 1)) : append
            return "\(path)/\(append)"
        }

        public func modifier(_ modifier: RequestModifierProtocol) -> Self {
            request = modifier.modify(request: request)
            return self
        }

        public func request<R: Decodable>(decoder: DataDecoderProtocol) async throws -> R {
            try await client.request(request: request, withRefresh: refresh, decoder: decoder)
        }
    }
}
