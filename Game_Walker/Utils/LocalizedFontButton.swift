//
//  LocalizedFontButton.swift
//  
//
//  Created by Paul on 1/25/24.
//

import Foundation
import UIKit

class LocalizedFontButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLocalizedFont()
    }

    func applyLocalizedFont() {
        if let languageCode = Locale.current.languageCode, languageCode == "ko" {
            // Apply Korean font
            if let currentFontSize = titleLabel?.font.pointSize {
                let customFont = UIFont(name: "koverwatch", size: fontSize(size: currentFontSize))
                titleLabel?.font = customFont
            }
        }
        // Fallback to default font for English or other languages
    }
    
    func fontSize(size: CGFloat) -> CGFloat {
        let size_formatter = size/390
        let result = UIScreen.main.bounds.size.width * size_formatter
        return result
    }
}
