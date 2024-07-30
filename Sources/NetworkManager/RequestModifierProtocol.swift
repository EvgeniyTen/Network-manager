
import Foundation

public protocol RequestModifierProtocol {
    func modify(request: URLRequest) -> URLRequest
}
