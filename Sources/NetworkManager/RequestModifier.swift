import Foundation

public struct BearerRequestModifier: RequestModifierProtocol {
    let token: String

    public init(token: String) {
        self.token = token
    }

    public func modify(request: URLRequest) -> URLRequest {
        var request = request
        request.addValue(
            Network.HTTPAuthentication.bearer(token: token).value,
            forHTTPHeaderField: Network.HTTPHeader.authorization.value)
        return request
    }
}
