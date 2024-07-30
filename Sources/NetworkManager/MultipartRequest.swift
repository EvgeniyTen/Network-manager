import Foundation
import UniformTypeIdentifiers

public protocol MultipartRequestProtocol {
    var httpContentTypeHeader: String { get }
    func httpBody(from url: URL) throws -> Data
}

public final class MultipartRequest: MultipartRequestProtocol {
    public var httpContentTypeHeader: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    public func httpBody(from url: URL) throws -> Data {
        var httpBody = Data()
        let fileName = url.lastPathComponent
        let fileData = try Data(contentsOf: url)
        let mimeType = self.mimeType(for: url.pathExtension)

        httpBody.appendString(boundarySeparator)
        httpBody.appendString(disposition(fileName))
        httpBody.appendString(contentType(mimeType))
        httpBody.append(fileData)
        httpBody.appendString(separator)
        httpBody.appendString(endBoundary)
        return httpBody
    }

    private var boundary: String = UUID().uuidString
    private var separator: String { "\r\n" }
    private var boundarySeparator: String { "--\(boundary)\(separator)" }
    private var endBoundary: String { "--\(boundary)--\(separator)" }

    private func disposition(_ fileName: String) -> String {
        "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)" + separator
    }

    private func contentType(_ mimeType: String) -> String {
        "Content-Type: \(mimeType)" + separator + separator
    }

    private func mimeType(for fileExtension: String) -> String {
        if let type = UTType(filenameExtension: fileExtension),
           let mimeType = type.preferredMIMEType {
            return mimeType
        }
        return "application/octet-stream"
    }
}
