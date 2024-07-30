import Foundation

public enum Network {
    public enum MultipartHTTPMethod: String {
        case post = "POST"
        case put = "PUT"
    }
    
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    public enum Status: Equatable {
        case success
        case multiplyChoises
        case badRequest
        case notAuthorized
        case forbidden
        case notFound
        case internalServerError
        case badGateway
        case serviceUnavailable
        case other(Int)

        init(rawValue: Int) {
            switch rawValue {
            case 200:
                self = .success
            case 300:
                self = .multiplyChoises
            case 400:
                self = .badRequest
            case 401:
                self = .notAuthorized
            case 403:
                self = .forbidden
            case 404:
                self = .notFound
            case 500:
                self = .internalServerError
            case 502:
                self = .serviceUnavailable
            case 503:
                self = .serviceUnavailable
            default:
                self = .other(rawValue)
            }
        }

        public var value: Int {
            switch self {
            case .success:
                return 200
            case .multiplyChoises:
                return 300
            case .badRequest:
                return 400
            case .notAuthorized:
                return 401
            case .forbidden:
                return 403
            case .notFound:
                return 404
            case .internalServerError:
                return 500
            case .badGateway:
                return 502
            case .serviceUnavailable:
                return 503
            case .other(let code):
                return code
            }
        }

        public static func successCodes() -> Range<Int> {
            Self.success.value..<Self.multiplyChoises.value
        }
    }

    public enum HTTPHeader: Hashable {
        /// A-IM    Acceptable instance-manipulations for the request.
        case aim
        /// Accept    Media type(s) that is/are acceptable for the response.
        case accept
        /// Accept-Charset    Character sets that are acceptable.
        case acceptCharset
        /// Accept-Datetime    Acceptable version in time.
        case acceptDatetime
        /// Accept-Encoding    List of acceptable encodings.
        case acceptEncoding
        /// Accept-Language    List of acceptable human languages for response.
        case acceptLanguage
        /// Authorization    Authentication credentials for HTTP authentication.
        case authorization
        /// Cache-Control    Used to specify directives that must be obeyed by all caching mechanisms along the request-response chain.
        case cacheControl
        /// Connection    Control options for the current connection and list of hop-by-hop request fields.
        case connection
        /// Content-Encoding    The type of encoding used on the data. See HTTP compression.
        case contentEncoding
        /// Content-Length    The length of the request body in octets (8-bit bytes).
        case contentLength
        /// Content-Type    The Media type of the body of the request.
        case contentType
        /// Cookie    An HTTP cookie previously sent by the server with Set-Cookie.
        case cookie
        /// Date    The date and time at which the message was originated.
        case date
        /// Expect    Indicates that particular server behaviors are required by the client.
        case expect
        /// From    The email address of the user making the request.
        case from
        /// Host    The domain name of the server (for virtual hosting), and the TCP port number on which the server is listening.
        case host
        /// If-Match    Only perform the action if the client supplied entity matches the same entity on the server.
        case ifMatch
        /// If-Modified-Since    Allows a 304 Not Modified to be returned if content is unchanged.
        case ifModifiedSince
        /// If-None-Match    Allows a 304 Not Modified to be returned if content is unchanged, see HTTP ETag.
        case ifNoneMatch
        /// If-Range    If the entity is unchanged, send me the part(s) that I am missing; otherwise, send me the entire new entity.
        case ifRange
        /// If-Unmodified-Since    Only send the response if the entity has not been modified since a specific time.
        case ifUnmodifiedSince
        /// Max-Forwards    Limit the number of times the message can be forwarded through proxies or gateways.
        case maxForwards
        /// Pragma    Implementation-specific fields that may have various effects anywhere along the request-response chain.
        case pragma
        /// Prefer    Allows client to request that certain behaviors be employed by a server while processing a request.
        case prefer
        /// Range    Request only part of an entity. Bytes are numbered from 0.
        case range
        /// Referer   This is the address of the previous web page from which a link to the currently requested page was followed.
        case referer
        /// Transfer-Encoding    The form of encoding used to safely transfer the entity to the user.
        case transferEncoding
        /// User-Agent    The user agent string of the user agent.
        case userAgent
        /// Any custom header
        case custom(String)

        public var value: String {
            switch self {
            case .aim: "A-IM"
            case .accept: "Accept"
            case .acceptCharset: "Accept-Charset"
            case .acceptDatetime: "Accept-Datetime"
            case .acceptEncoding: "Accept-Encoding"
            case .acceptLanguage: "Accept-Language"
            case .authorization: "Authorization"
            case .cacheControl: "Cache-Control"
            case .connection: "Connection"
            case .contentEncoding: "Content-Encoding"
            case .contentLength: "Content-Length"
            case .contentType: "Content-Type"
            case .cookie: "Cookie"
            case .date: "Date"
            case .expect: "Expect"
            case .from: "From"
            case .host: "Host"
            case .ifMatch: "If-Match"
            case .ifModifiedSince: "If-Modified-Since"
            case .ifNoneMatch: "If-None-Match"
            case .ifRange: "If-Range"
            case .ifUnmodifiedSince: "If-Unmodified-Since"
            case .maxForwards: "Max-Forwards"
            case .pragma: "Pragma"
            case .prefer: "Prefer"
            case .range: "Range"
            case .referer: "Referer"
            case .transferEncoding: "Transfer-Encoding"
            case .userAgent: "User-Agent"
            case let .custom(header): header
            }
        }
    }

    public enum Error: Swift.Error {
        case unableConstructURL
        case unableCounstructURLWithParameters
        case unableAddBody
        case unableEncodeBody(Swift.Error)
        case emptyResponseData
        case corruptedData(Swift.Error)
        case serverStatusData(status: Network.Status,
                              errorData: Data)
        case serverStatus(status: Network.Status,
                          errorMessage: Decodable?,
                          decodeError: Swift.Error?)
    }

    public enum HTTPAuthentication {
        case basic(token: String)
        case bearer(token: String)
        case other(fullHeader: String)

        public var value: String {
            switch self {
            case .basic(let token):
                return "Basic \(token)"
            case .bearer(let token):
                return "Bearer \(token)"
            case .other(let fullHeader):
                return fullHeader
            }
        }
    }

    public struct Refresh {
        let status: Network.Status
        let action: () async throws -> Void
        public init(status: Network.Status, action: @escaping () async throws -> Void) {
            self.status = status
            self.action = action
        }
    }
}
