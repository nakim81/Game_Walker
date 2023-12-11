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
