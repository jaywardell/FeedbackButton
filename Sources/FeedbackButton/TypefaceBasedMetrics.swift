//
//  TypefaceBasedMetrics.swift
//  Leebree
//
//  Created by Joseph Wardell on 5/3/23.
//

import SwiftUI

extension Double {

    // swiftlint:disable:next identifier_name
    var em: CGFloat {
#if canImport(AppKit)
        let bodyFontSize = NSFont.preferredFont(forTextStyle: .body).pointSize
#elseif canImport(UIKit)
        let bodyFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
#endif
        return bodyFontSize * self
    }
}
