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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 17)
        label.numberOfLines = 0
        return label
    }()
    
    private let backGroundView: UIImageView = {
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
        return view
    }()
    
    private var teamIconImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let teamNumLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 20)
        label.numberOfLines = 1
        return label
    }()
    
    private var teamNameLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 15)
        label.numberOfLines = 1
        return label
    }()
    
    private var scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 23)
        label.numberOfLines = 0
        return label
    }()

    public let borderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 85, width: 330, height: 2))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
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
            containerView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 330),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 203),
            nameLabel.heightAnchor.constraint(equalToConstant: 27),
            
            backGroundView.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor),
            backGroundView.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            backGroundView.widthAnchor.constraint(equalToConstant: 328),
            backGroundView.heightAnchor.constraint(equalToConstant: 47)
        ])
        nameLabel.text = name
    
    }
    
    func configureRankTableViewCellWithScore(imageName: String, teamNum: String, teamName: String, points: String) {
        contentView.addSubview(containerView)
        contentView.addSubview(borderView)
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
                teamIconImage.heightAnchor.constraint(equalTo: containerView.heightAnchor),
                teamIconImage.widthAnchor.constraint(equalTo: teamIconImage.heightAnchor),
                
                teamNumLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                teamNumLabel.topAnchor.constraint(equalTo: teamIconImage.topAnchor, constant: 5),
                teamNumLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
                teamNumLabel.widthAnchor.constraint(equalToConstant: 120),
                
                teamNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                teamNameLabel.bottomAnchor.constraint(equalTo: teamIconImage.bottomAnchor, constant: -5),
                teamNameLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
                teamNameLabel.widthAnchor.constraint(equalToConstant: 120),
                
                scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                scoreLabel.centerYAnchor.constraint(equalTo: teamIconImage.centerYAnchor),
                scoreLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1),
                scoreLabel.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
                
                borderView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
                borderView.heightAnchor.constraint(equalToConstant: 2.0),
                borderView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
                borderView.topAnchor.constraint(equalTo: teamIconImage.bottomAnchor, constant: 6)
            ])
            teamIconImage.image = UIImage(named: imageName)
            teamNameLabel.text = teamName
            teamNumLabel.text = teamNum
            scoreLabel.text = points
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
