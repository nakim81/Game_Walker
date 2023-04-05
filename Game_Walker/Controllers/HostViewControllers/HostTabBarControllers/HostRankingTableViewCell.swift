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
    
    private let teamNumLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 18)
        label.numberOfLines = 0
        return label
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
        label.font = UIFont(name: "Dosis-Regular", size: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private var scoreLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 20)
        label.numberOfLines = 0
        return label
    }()

    private let borderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 85, width: 330, height: 2))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureRankTableViewCell(imageName: String, teamNum: String, teamName: String, points: Int, showScore: Bool) {
        contentView.addSubview(containerView)
        containerView.addSubview(teamIconImage)
        containerView.addSubview(teamNameLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(borderView)
        containerView.addSubview(teamNumLabel)
        
        if (showScore) {
            scoreLabel.textColor = .black
        } else {
            scoreLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        }
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 330),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            
            teamNumLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            teamNumLabel.leadingAnchor.constraint(equalTo: teamIconImage.layoutMarginsGuide.trailingAnchor, constant: 5),
            teamNumLabel.trailingAnchor.constraint(equalTo: teamNameLabel.leadingAnchor),
            teamNumLabel.heightAnchor.constraint(equalToConstant: 23),
            
            teamNameLabel.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor, constant: 35),
            teamNameLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            teamNameLabel.widthAnchor.constraint(equalToConstant: 100),
            teamNameLabel.heightAnchor.constraint(equalToConstant: 25),
            
            scoreLabel.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor, constant: 110),
            scoreLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            scoreLabel.widthAnchor.constraint(equalToConstant: 70),
            scoreLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        teamIconImage.centerXAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerXAnchor, constant: -120).isActive = true
        teamIconImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        teamIconImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        teamIconImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        teamIconImage.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        teamNumLabel.text = teamNum
        scoreLabel.text = String(points)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
