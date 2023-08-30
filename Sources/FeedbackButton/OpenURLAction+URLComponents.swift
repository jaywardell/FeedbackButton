//
//  OpenURLAction+URLComponents.swift
//  DailyWeatherGraphs
//
//  Created by Joseph Wardell on 6/1/23.
//

import SwiftUI

extension OpenURLAction {

    @discardableResult
    func open(_ components: URLComponents) -> Bool {
        guard let url = components.url else { return false }

        self(url)
        return true
    }
}
