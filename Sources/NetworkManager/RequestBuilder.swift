import Foundation
import Combine

extension Network {
    public class BodyableRequestBuilder: Network.RequestBuilder, BodyableRequestBuilderProtocol {
        @discardableResult
        public func body(_ body: Encodable,
                         encoder: DataEncoderProtocol = JSONEncoder()) throws -> RequestBuilderProtocol {
            guard urlRequest.httpMethod != Network.HTTPMethod.get.rawValue else {
                throw Network.Error.unableAddBody
            }

            do {
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                throw Network.Error.unableEncodeBody(error)
            }
            return self
        }
    }

    public class RequestBuilder: RequestBuilderProtocol {
        private let client: NetworkServiceProtocol
        public let httpMethod: HTTPMethod
        public var urlRequest: URLRequest
        private var refresh = false

        public init(
            client: NetworkServiceProtocol,
            baseURL: String,
            method: HTTPMethod,
            path: String
        ) throws {
            guard let url = URL(string: baseURL),
                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw Network.Error.unableConstructURL
            }
            components.path = Self.createPath(path: components.path, append: path)

            self.client = client

            guard let url = components.url else {
                throw Network.Error.unableCounstructURLWithParameters
            }
            self.httpMethod = method
            self.urlRequest = URLRequest(url: url)
            self.urlRequest.httpMethod = method.rawValue
        }

        public convenience init(
            client: NetworkServiceProtocol,
            baseURL: String,
            method: MultipartHTTPMethod,
            fileURL: URL,
            path: String
        ) throws {
            try self.init(
                client: client,
                baseURL: baseURL,
                method: Self.availableTypeFor(method),
                path: path
            )
            let multipartRequest = MultipartRequest()
            urlRequest.setValue(
                multipartRequest.httpContentTypeHeader,
                forHTTPHeaderField: "Content-Type"
            )
            urlRequest.httpBody = try multipartRequest.httpBody(from: fileURL)
        }

        @discardableResult
        public func queryItems(_ items: [URLQueryItem]) throws -> Self {
            guard let url = urlRequest.url,
                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw Network.Error.unableConstructURL
            }

            components.queryItems = items
            guard let url = components.url else {
                throw Network.Error.unableCounstructURLWithParameters
            }

            urlRequest.url = url
            return self
        }

        @discardableResult
        public func headers(_ headers: [Network.HTTPHeader: String]) -> Self {
            headers.forEach {
                urlRequest.setValue($0.value, forHTTPHeaderField: $0.key.value)
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

        private static func availableTypeFor(_ htttpType: MultipartHTTPMethod) -> HTTPMethod {
            /// метод такого топорного вида потребовался для того, что бы
            /// исключить формирование дефолтного значения при попытке
            /// достать кейс энама через rawValue
            switch htttpType {
            case .post:
                return .post
            case .put:
                return .put
            }
        }

        public func modifier(_ modifier: RequestModifierProtocol) -> Self {
            urlRequest = modifier.modify(request: urlRequest)
            return self
        }

        public func request<R: Decodable>(decoder: DataDecoderProtocol) async throws -> R {
            try await client.request(request: urlRequest, withRefresh: refresh, decoder: decoder)
        }
    }
}
