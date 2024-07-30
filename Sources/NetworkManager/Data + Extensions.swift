//
//  File.swift
//  
//
//  Created by Evgeniy Timofeev on 30.07.2024.
//

import Foundation

public extension Data {

    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }

    mutating func appendString(_ string: String) {
        guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) else { return }
        append(data)
    }
}
