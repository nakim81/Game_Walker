//
//  UITableViewCellExtensions.swift
//  Game_Walker
//
//  Created by Noah Kim on 12/4/23.
//

import Foundation
import UIKit

extension UITableViewCell {
    func fontSize(size: CGFloat) -> CGFloat {
        let size_formatter = size/390
        let result = UIScreen.main.bounds.size.width * size_formatter
        return result
    }
    
}

//MARK: - Language

extension UITableViewCell {
    func getFontForLanguage(font: String, size: CGFloat, ksize: CGFloat? = nil) -> UIFont {
        let finalSize = fontSize(size: ksize ?? size)
        
        if let languageCode = Locale.current.languageCode, languageCode == "ko" {
            if let customFont = UIFont(name: "koverwatch", size: finalSize) {
                return customFont
            }
        }
        
        // Fallback to default font for English or other languages
        if let defaultFont = UIFont(name: font, size: finalSize) {
            return defaultFont
        }
        
        // If both custom and default fonts are unavailable, return system font
        return UIFont.systemFont(ofSize: finalSize)
    }
}
