//
//  IconCollectionViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import UIKit

class TeamIconCollectionViewCell: UICollectionViewCell {
    
    private var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    private var imageName: String?
    private var teamNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont(name: "Dosis-Regular", size: 12)
        label.textAlignment = .center
        return label
    }()
    private var teamNumLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont(name: "Dosis-Bold", size: 15)
        label.textAlignment = .center
        return label
    }()
    
    private let borderView = UIView(frame: CGRect(x: -5, y: 0, width: 70, height: 70))
    
    static let identifier = "IconCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.addSubview(imageView)
        contentView.addSubview(teamNameLabel)
        contentView.addSubview(borderView)
        contentView.addSubview(teamNumLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func configureCreateTeamCell(_ imageName: String) {
        self.imageName = imageName
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.image = UIImage(named: imageName)
    }
    
    func configureJoinTeamCell(imageName: String, teamName: String, teamNum: String) {
        self.imageName = imageName
        imageView.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        teamNumLabel.text = teamNum
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -15),
            imageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1),
            
            teamNumLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            teamNumLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            teamNumLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            teamNumLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            teamNumLabel.heightAnchor.constraint(equalTo: teamNumLabel.widthAnchor, multiplier: 0.37),
            
            teamNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            teamNameLabel.topAnchor.constraint(equalTo: teamNumLabel.bottomAnchor, constant: 2),
            teamNameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 2),
            teamNameLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -2),
            teamNameLabel.heightAnchor.constraint(equalTo: teamNameLabel.widthAnchor, multiplier: 0.35)
        ])
    }
    
    func showBorder() {
        borderView.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
        borderView.layer.borderWidth = 1
        borderView.layer.cornerRadius = borderView.layer.bounds.width / 2
    }
    
    func hideBorder() {
        borderView.layer.borderWidth = 0
    }
}
