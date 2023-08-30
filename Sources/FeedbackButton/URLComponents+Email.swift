//
//  URLComponents+Email.swift
//  Leebree
//
//  Created by Joseph Wardell on 6/1/23.
//

import Foundation

extension URLComponents {

    init(emailTo address: String, subject: String? = nil, body: String? = nil) {
        self.init()
        
        self.scheme = "mailto"
        self.path = address
        self.queryItems = []
        if let subject {
            self.queryItems?.append(URLQueryItem(name: "subject", value: subject))
        }
        if let body {
            self.queryItems?.append(URLQueryItem(name: "body", value: body))
        }
    }
}
