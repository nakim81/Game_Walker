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
    
    lazy var messageNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont(name: "Dosis-Regular", size: 20)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 10
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func configureTableViewCell(name: String, read: Bool, role: String) {
        contentView.addSubview(containerView)
        containerView.addSubview(messageNameLabel)
        
        chooseBackgroundColor(role: role)
        
        if (read) {
            containerView.layer.borderColor = UIColor.lightText.cgColor
            messageNameLabel.textColor = .lightText
        } else {
            containerView.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
            messageNameLabel.textColor = .white
        }
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            messageNameLabel.widthAnchor.constraint(equalTo: containerView.layoutMarginsGuide.widthAnchor),
            messageNameLabel.heightAnchor.constraint(equalTo: containerView.layoutMarginsGuide.heightAnchor),
            messageNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            messageNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        messageNameLabel.text = name
    }
    
    private func chooseBackgroundColor(role: String) {
        switch (role) {
        case "player":
            contentView.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
        case "referee":
            contentView.backgroundColor = UIColor(red: 0.333, green: 0.745, blue: 0.459, alpha: 1)
        default:
            contentView.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
        }
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
