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
    private let blindImage = UIImage(named: "blindScore")
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 25)
        label.numberOfLines = 0
        return label
    }()
    
    private let backGroundView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var teamIconImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var teamNumLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-SemiBold", size: fontSize(size: 20))
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var teamNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 15))
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-SemiBold", size: fontSize(size: 22))
        label.numberOfLines = 1
        return label
    }()
    
    public lazy var borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureTeamTableViewCell(name: String) {
        contentView.addSubview(containerView)
        containerView.addSubview(backGroundView)
        containerView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            backGroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backGroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backGroundView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            backGroundView.heightAnchor.constraint(equalToConstant: 50)
        ])
        nameLabel.text = name
        
    }
    
    func configureRankTableViewCellWithScore(imageName: String, teamNum: String, teamName: String, points: String, showScore: Bool) {
        contentView.addSubview(containerView)
        containerView.addSubview(borderView)
        containerView.addSubview(teamIconImage)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(teamNumLabel)
        containerView.addSubview(teamNameLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            teamIconImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            teamIconImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            teamIconImage.heightAnchor.constraint(equalToConstant: 70),
            teamIconImage.widthAnchor.constraint(equalToConstant: 70),
            
            NSLayoutConstraint(item: teamNumLabel, attribute: .leading, relatedBy: .equal, toItem: teamIconImage, attribute: .trailing, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: teamNumLabel, attribute: .trailing, relatedBy: .equal, toItem: scoreLabel, attribute: .leading, multiplier: 1, constant: 0),
            teamNumLabel.topAnchor.constraint(equalTo: teamIconImage.topAnchor, constant: 5),
            teamNumLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
            
            teamNameLabel.bottomAnchor.constraint(equalTo: teamIconImage.bottomAnchor, constant: -5),
            teamNameLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
            teamNameLabel.leadingAnchor.constraint(equalTo: teamNumLabel.leadingAnchor),
            teamNameLabel.trailingAnchor.constraint(equalTo: teamNumLabel.trailingAnchor),
            
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: teamIconImage.centerYAnchor),
            scoreLabel.widthAnchor.constraint(equalTo: containerView.heightAnchor),
            
            borderView.widthAnchor.constraint(equalTo: containerView.layoutMarginsGuide.widthAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 3.0),
            borderView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            borderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        teamIconImage.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        teamNumLabel.text = teamNum
        if showScore {
            scoreLabel.text = points
            scoreLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1).isActive = true
            scoreLabel.backgroundColor = .clear
        } else {
            scoreLabel.text = ""
            scoreLabel.backgroundColor = UIColor(patternImage: blindImage!)
            scoreLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.2).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
