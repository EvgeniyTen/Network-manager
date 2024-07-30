import Foundation

public protocol DataEncoderProtocol {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}

public protocol DataDecoderProtocol {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

extension JSONEncoder: DataEncoderProtocol {}
extension JSONDecoder: DataDecoderProtocol {}
