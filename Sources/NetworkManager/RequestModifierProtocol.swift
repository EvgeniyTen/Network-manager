//
//  File.swift
//  
//
//  Created by Evgeniy Timofeev on 18.02.2024.
//

import Foundation

public protocol RequestModifierProtocol {
    func modify(request: URLRequest) -> URLRequest
}
