//
//  TeamTableViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 7/22/22.
//

import Foundation
import UIKit

class TeamTableViewCell: UITableViewCell {
    
    static let identifier = "TeamTableViewCell"
    
    lazy var nameLabel: UILabel = {
            let label = UILabel()
            label.contentMode = .scaleAspectFit
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
//            backgroundColor = .red
            addSubview(nameLabel)
            NSLayoutConstraint.activate([
                nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            nameLabel.font = UIFont(name: "Dosis-Bold", size: 20)
        }
        
        func setupCell(name: String) {
            nameLabel.text = name
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
