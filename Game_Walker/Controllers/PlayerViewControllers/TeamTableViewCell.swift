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
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private let imageview: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "name box fill 1")
        view.alpha = 0.5
        return view
    }()
    
    private lazy var containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            return view
        }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    func configureTableViewCell(name: String) {
        contentView.addSubview(containerView)
        containerView.addSubview(imageview)
        containerView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 330),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 203),
            nameLabel.heightAnchor.constraint(equalToConstant: 19),
            
            imageview.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor),
            imageview.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            imageview.widthAnchor.constraint(equalToConstant: 328),
            imageview.heightAnchor.constraint(equalToConstant: 47)
        ])
        nameLabel.text = name
    
    }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
