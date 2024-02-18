import Foundation

@available(iOS 15.0.0, *)
public protocol DataEncoderProtocol {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}

@available(iOS 15.0.0, *)
public protocol DataDecoderProtocol {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}
@available(iOS 15.0.0, *)
extension JSONEncoder: DataEncoderProtocol {}

@available(iOS 15.0.0, *)
extension JSONDecoder: DataDecoderProtocol {}
