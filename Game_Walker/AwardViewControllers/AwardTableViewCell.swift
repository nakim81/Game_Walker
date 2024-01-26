//
//  AwardTableViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/20/23.
//

import Foundation
import UIKit

class AwardTableViewCell: UITableViewCell {
    
    static let identifier = "AwardTableViewCell"
    
    private let teamNumLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
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
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private var scoreLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLabel()
    }
    
    private func configureLabel(){
        teamNumLabel.font = getFontForLanguage(font: "Dosis-Regular", size: 25)
        teamNameLabel.font = getFontForLanguage(font: "Dosis-Regular", size: 15)
        scoreLabel.font = getFontForLanguage(font: "Dosis-SemiBold", size: 25)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    
    func configureRankTableViewCell(imageName: String, teamNum: String, teamName: String, points: Int) {
        contentView.addSubview(containerView)
        containerView.addSubview(teamIconImage)
        containerView.addSubview(teamNameLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(teamNumLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            teamIconImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            teamIconImage.widthAnchor.constraint(equalToConstant: 70),
            teamIconImage.heightAnchor.constraint(equalTo: teamIconImage.widthAnchor, multiplier: 1),
            teamIconImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            teamNumLabel.topAnchor.constraint(equalTo: teamIconImage.topAnchor, constant: 5),
            teamNumLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: teamIconImage.trailingAnchor, multiplier: 1),
            teamNumLabel.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor),
            teamNumLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
    
            teamNameLabel.leadingAnchor.constraint(equalTo: teamNumLabel.leadingAnchor),
            teamNameLabel.trailingAnchor.constraint(equalTo: teamNumLabel.trailingAnchor),
            teamNameLabel.heightAnchor.constraint(equalTo: teamNumLabel.heightAnchor, multiplier: 1),
            teamNameLabel.bottomAnchor.constraint(equalTo: teamIconImage.bottomAnchor, constant: -5),
            
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            scoreLabel.widthAnchor.constraint(equalToConstant: 35),
            scoreLabel.heightAnchor.constraint(equalToConstant: 30)
        ])

        teamIconImage.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        teamNumLabel.text = teamNum
        scoreLabel.text = String(points)
    }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
