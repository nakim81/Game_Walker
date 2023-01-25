//
//  MessageTableViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 1/25/23.
//

import Foundation
import UIKit

class MessageTableViewCell: UITableViewCell {
    
    static let identifier = "MessageTableViewCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var messageNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 15)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label
    }()
    
    func configureTableViewCell(name: String) {
        contentView.addSubview(containerView)
        containerView.addSubview(messageNameLabel)
        messageNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.143),
            
            messageNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            messageNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            messageNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            messageNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            messageNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        messageNameLabel.text = name
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")

    }
    
}
