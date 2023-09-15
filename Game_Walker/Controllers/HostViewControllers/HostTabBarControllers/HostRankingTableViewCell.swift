//
//  HostRankingTableViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/2/23.
//

import Foundation
import UIKit

class HostRankingTableViewCell: UITableViewCell {
    
    static let identifier = "HostRankingTableViewCell"
    
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
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-SemiBold", size: 20)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var teamNameLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 15)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-SemiBold", size: 25)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var stationNameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Medium", size: 13)
        label.numberOfLines = 2
        return label
    }()

    private lazy var borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureRankTableViewCell(imageName: String, teamNum: String, teamName: String, stationName: String, points: Int, showScore: Bool) {
        contentView.addSubview(containerView)
        containerView.addSubview(teamIconImage)
        containerView.addSubview(teamNumLabel)
        containerView.addSubview(teamNameLabel)
        containerView.addSubview(stationNameLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            teamIconImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            teamIconImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            teamIconImage.heightAnchor.constraint(equalToConstant: 60),
            teamIconImage.widthAnchor.constraint(equalTo: teamIconImage.heightAnchor),
            
            NSLayoutConstraint(item: teamNumLabel, attribute: .leading, relatedBy: .equal, toItem: teamIconImage, attribute: .trailing, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: teamNumLabel, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0),
            teamNumLabel.topAnchor.constraint(equalTo: teamIconImage.topAnchor, constant: 5),
            teamNumLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
            
            teamNameLabel.bottomAnchor.constraint(equalTo: teamIconImage.bottomAnchor, constant: -5),
            teamNameLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
            teamNameLabel.leadingAnchor.constraint(equalTo: teamNumLabel.leadingAnchor),
            teamNameLabel.trailingAnchor.constraint(equalTo: teamNumLabel.trailingAnchor),
            
            stationNameLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor),
            stationNameLabel.trailingAnchor.constraint(equalTo: scoreLabel.layoutMarginsGuide.leadingAnchor, constant: -5),
            stationNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stationNameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5),
            
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: teamIconImage.centerYAnchor),
            scoreLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1),
            scoreLabel.widthAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.8),
            
            borderView.widthAnchor.constraint(equalTo: containerView.layoutMarginsGuide.widthAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 3.0),
            borderView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            borderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        teamIconImage.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        teamNumLabel.text = teamNum
        stationNameLabel.text = stationName
        scoreLabel.text = String(points)
        if (showScore) {
            scoreLabel.textColor = .black
        } else {
            scoreLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
