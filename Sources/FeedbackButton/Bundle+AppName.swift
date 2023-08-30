//
//  File.swift
//  
//
//  Created by Joseph Wardell on 8/30/23.
//

import SwiftUI

extension Bundle {

    var appName: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "This app" }
}
