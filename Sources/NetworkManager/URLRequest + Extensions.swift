import Foundation

public extension URLRequest {
    mutating func updateHttpBody(with newPart: Data) {
        self.httpBody?.append(newPart)
    }
}
