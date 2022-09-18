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
    let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(nameLabel)
    }

    func configureTableViewCell(name: String) {
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        self.translatesAutoresizingMaskIntoConstraints = true

        self.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        self.widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameLabel.clipsToBounds = true
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = name
        nameLabel.font = UIFont(name: "Dosis-Bold", size: 25)
        nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 23).isActive = true
    }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
