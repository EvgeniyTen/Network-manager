import Foundation
import Combine

@available(iOS 15.0.0, *)
public protocol RequestBuilderProtocol {
    /**
     Adds query items to request
     - parameter items: array of url params
     - returns: Self
     
     # Example #
     ```
     self.queryItems([
       URLQueryItem(name: "key1", value: "value1"),
       URLQueryItem(name: "key2", value: "value2")
     ])
     ```
     **/
    @discardableResult
    func queryItems(_ items: [URLQueryItem]) throws -> Self
    /**
     Adds headers to request
     - parameter headers: array of url params
     - returns: Self
     
     # Example #
     ```
     self.headers([.custom("custom"): "value"])
     ```
     **/
    @discardableResult
    func headers(_ headers: [Network.HTTPHeader: String]) -> Self
    /**
     Adds body to request
     - parameter body: Encodable type
     - parameter encoder: Encoder to encode body
     - returns: Self
     
     # Example #
     ```
     self.body("some value", JSONEncoder())
     ```
     **/
    @discardableResult
    func body(_ body: Encodable, encoder: DataEncoderProtocol) throws -> Self

    /**
     Adds modifier
     - parameter modifier: A modifier which will be applyed to request
     - returns: Self
     
     # Example #
     ```
     self.modifier(RequestModifier())
     ```
     **/
    @discardableResult
    func modifier(_ modifier: RequestModifierProtocol) -> Self

    /**
     Adds refresh action
     - returns: Self
     
     # Example #
     ```
     self.withRefresh()
     ```
     **/
    @discardableResult
    func withRefresh() -> Self

    /**
     Sends request to network
     - parameter decoder: Decoder for responce
     - returns: Decoded data arrived by network
     
     # Example #
     ```
     self.request(decoder: JSONDecoder())
     ```
     **/
    func request<R: Decodable>(decoder: DataDecoderProtocol) async throws -> R
}

@available(iOS 15.0.0, *)
public extension RequestBuilderProtocol {
    /**
     Adds body to request
     - parameter body: Encodable type with default JSONEncoder
     - returns: Self
     
     # Example #
     ```
     self.body("some value")
     ```
     **/
    @discardableResult
    func body(_ body: Encodable) throws -> Self {
        try self.body(body, encoder: JSONEncoder())
    }

    /**
     Request data via network, using setted params
     
     # Example #
     ```
     self.request()
     ```
     **/
    func request() async throws {
        let _: Data = try await request()
    }

    /**
     Request data via network, using setted params, and decodes  with JSONDecoder
     - returns: Decoded responce
     
     # Example #
     ```
     self.request()
     ```
     **/
    func request<R: Decodable>() async throws -> R {
        try await request(decoder: JSONDecoder())
    }

    /**
     Request data via network, using setted params
     - parameter decoder: Decoder for response
     - returns: Future containing decoded response or Error
     
     # Example #
     ```
     self.future(decoder: JSONDecoder())
     ```
     **/
    func future<R: Decodable>(decoder: DataDecoderProtocol) -> Future<R, Error> {
        Future {
            try await self.request(decoder: decoder)
        }
    }

    /**
     Request data via network, using setted params, and decodes  with JSONDecoder
     - returns: Future containing response or Error
     
     # Example #
     ```
     self.future()
     ```
     **/
    func future<R: Decodable>() -> Future<R, Error> {
        future(decoder: JSONDecoder())
    }
}
