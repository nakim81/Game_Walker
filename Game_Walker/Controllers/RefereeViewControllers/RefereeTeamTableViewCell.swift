//
//  RefereeTeamTableViewCell.swift
//  Game_Walker
//
//  Created by 김현식 on 1/30/23.
//

import Foundation
import UIKit

class RefereeTeamTableViewCell: UITableViewCell {
    
    static let identifier = "RefereeTeamTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 20)
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
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var teamIconImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var teamNameLabel: UILabel = {
       let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private var scoreLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 25)
        label.numberOfLines = 0
        return label
    }()

    private let borderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 85, width: 330, height: 2))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
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
    
    func configureRankTableViewCell(imageName: String, teamName: String, points: Int) {
        contentView.addSubview(containerView)
        containerView.addSubview(teamIconImage)
        containerView.addSubview(teamNameLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 330),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            
            teamNameLabel.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor),
            teamNameLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            teamNameLabel.widthAnchor.constraint(equalToConstant: 130),
            teamNameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            scoreLabel.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor, constant: 95),
            scoreLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            scoreLabel.widthAnchor.constraint(equalToConstant: 100),
            scoreLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        teamIconImage.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor, constant: -120).isActive = true
        teamIconImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        teamIconImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        teamIconImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        teamIconImage.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        scoreLabel.text = String(points)
    }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}

