//
//  AwardViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/20/23.
//

import Foundation
import UIKit

class AwardViewController: UIViewController {
    private let gameCode = UserData.readGamecode("gamecode") ?? ""
    private var teamList: [Team] = []
    private var newTeamList: [Team] = []
    private var firstPlace: Team?
    private var secondPlace: Team?
    private var thirdPlace: Team?
    
    private let leaderBoard = UITableView(frame: .zero)
    private let cellSpacingHeight: CGFloat = 3
    
    private let audioPlayerManager = AudioPlayerManager()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var congratulationLabel: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "CONGRATULATIONS 1")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var firstPlaceImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var firstPlaceTeamNum: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-SemiBold", size: 20)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var firstPlaceTeamName: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 18)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var firstPlacePoints: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 23)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var firstPlaceView: UIView = {
        let view = UIView()
        view.addSubview(firstPlaceImage)
        view.addSubview(firstPlaceTeamNum)
        view.addSubview(firstPlaceTeamName)
        view.addSubview(firstPlacePoints)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstPlaceImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstPlaceImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.884354),
            firstPlaceImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.613208),
            NSLayoutConstraint(item: firstPlaceImage, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            
            firstPlaceTeamNum.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstPlaceTeamNum.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            firstPlaceTeamNum.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.122642),
            NSLayoutConstraint(item: firstPlaceTeamNum, attribute: .top, relatedBy: .equal, toItem: firstPlaceImage, attribute: .bottom, multiplier: 1, constant: 0),
            
            firstPlaceTeamName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstPlaceTeamName.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            firstPlaceTeamName.heightAnchor.constraint(equalTo: firstPlaceImage.heightAnchor, multiplier: 0.176923),
            NSLayoutConstraint(item: firstPlaceTeamName, attribute: .top, relatedBy: .equal, toItem: firstPlaceTeamNum, attribute: .bottom, multiplier: 1, constant: 0),
            
            firstPlacePoints.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstPlacePoints.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            firstPlacePoints.heightAnchor.constraint(equalTo: firstPlaceImage.heightAnchor, multiplier: 0.230769),
            NSLayoutConstraint(item: firstPlacePoints, attribute: .top, relatedBy: .equal, toItem: firstPlaceTeamName, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        return view
    }()
    
    private lazy var secondPlaceImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var secondPlaceTeamNum: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-SemiBold", size: 15)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var secondPlaceTeamName: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 13)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var secondPlacePoints: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 18)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var secondPlaceView: UIView = {
        let view = UIView()
        view.addSubview(secondPlaceImage)
        view.addSubview(secondPlaceTeamNum)
        view.addSubview(secondPlaceTeamName)
        view.addSubview(secondPlacePoints)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            secondPlaceImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondPlaceImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.78),
            secondPlaceImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.613208),
            NSLayoutConstraint(item: secondPlaceImage, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            
            secondPlaceTeamNum.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondPlaceTeamNum.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            secondPlaceTeamNum.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.122642),
            NSLayoutConstraint(item: secondPlaceTeamNum, attribute: .top, relatedBy: .equal, toItem: secondPlaceImage, attribute: .bottom, multiplier: 1, constant: 0),
            
            secondPlaceTeamName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondPlaceTeamName.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            secondPlaceTeamName.heightAnchor.constraint(equalTo: secondPlaceImage.heightAnchor, multiplier: 0.176923),
            NSLayoutConstraint(item: secondPlaceTeamName, attribute: .top, relatedBy: .equal, toItem: secondPlaceTeamNum, attribute: .bottom, multiplier: 1, constant: 0),
            
            secondPlacePoints.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondPlacePoints.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            secondPlacePoints.heightAnchor.constraint(equalTo: secondPlaceImage.heightAnchor, multiplier: 0.230769),
            NSLayoutConstraint(item: secondPlacePoints, attribute: .top, relatedBy: .equal, toItem: secondPlaceTeamName, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        return view
    }()
    
    private lazy var thirdPlaceImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var thirdPlaceTeamNum: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-SemiBold", size: 15)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var thirdPlaceTeamName: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 13)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var thirdPlacePoints: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 18)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var thirdPlaceView: UIView = {
        let view = UIView()
        view.addSubview(thirdPlaceImage)
        view.addSubview(thirdPlaceTeamNum)
        view.addSubview(thirdPlaceTeamName)
        view.addSubview(thirdPlacePoints)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thirdPlaceImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thirdPlaceImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.78),
            thirdPlaceImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.613208),
            NSLayoutConstraint(item: thirdPlaceImage, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            
            thirdPlaceTeamNum.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thirdPlaceTeamNum.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            thirdPlaceTeamNum.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.122642),
            NSLayoutConstraint(item: thirdPlaceTeamNum, attribute: .top, relatedBy: .equal, toItem: thirdPlaceImage, attribute: .bottom, multiplier: 1, constant: 0),
            
            thirdPlaceTeamName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thirdPlaceTeamName.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            thirdPlaceTeamName.heightAnchor.constraint(equalTo: thirdPlaceImage.heightAnchor, multiplier: 0.176923),
            NSLayoutConstraint(item: thirdPlaceTeamName, attribute: .top, relatedBy: .equal, toItem: thirdPlaceTeamNum, attribute: .bottom, multiplier: 1, constant: 0),
            
            thirdPlacePoints.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thirdPlacePoints.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            thirdPlacePoints.heightAnchor.constraint(equalTo: thirdPlaceImage.heightAnchor, multiplier: 0.230769),
            NSLayoutConstraint(item: thirdPlacePoints, attribute: .top, relatedBy: .equal, toItem: thirdPlaceTeamName, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        return view
    }()
    
    private lazy var secondAndThirdPlaceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.addArrangedSubview(secondPlaceView)
        stackView.addArrangedSubview(thirdPlaceView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 31)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code" + "\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 10) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var logoImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "logo")
        
        return view
    }()
    
    private lazy var homeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "homeBtn"), for: .normal)
        button.addTarget(self, action: #selector(callMainVC), for: .touchUpInside)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var navStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.spacing = 0
        view.addArrangedSubview(logoImage)
        view.addArrangedSubview(gameCodeLabel)
        view.addArrangedSubview(homeBtn)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.audioPlayerManager.playAudioFile(named: "congrats_ending", withExtension: "wav")
        T.delegate_teamList = self
        T.getTeamList(gameCode)
        configureViews()
        Task {
            try await Task.sleep(nanoseconds: 300_000_000)
            self.firstPlace = teamList.first
            self.secondPlace = teamList[1]
            self.thirdPlace = teamList[2]
            configureTopThree()
            newTeamList = getNewTeamList(teamList)
            configureLeaderboard()
        }
    }
    
    func configureViews() {
        view.addSubview(containerView)
        containerView.addSubview(congratulationLabel)
        containerView.addSubview(firstPlaceView)
        containerView.addSubview(secondAndThirdPlaceStackView)
        containerView.addSubview(leaderBoard)
        containerView.addSubview(navStackView)
        leaderBoard.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            navStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            navStackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.780322),
            navStackView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.05),
            NSLayoutConstraint(item: navStackView, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 0.2, constant: 0),
            
            congratulationLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            congratulationLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.780322),
            congratulationLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.0658762),
            NSLayoutConstraint(item: congratulationLabel, attribute: .top, relatedBy: .equal, toItem: navStackView, attribute: .bottom, multiplier: 1.1, constant: 0),
            
            firstPlaceView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            firstPlaceView.widthAnchor.constraint(equalTo: congratulationLabel.widthAnchor, multiplier: 0.47),
            firstPlaceView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.25),
            NSLayoutConstraint(item: firstPlaceView, attribute: .top, relatedBy: .equal, toItem: congratulationLabel, attribute: .bottom, multiplier: 0.9, constant: 0),
            
            secondAndThirdPlaceStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            secondAndThirdPlaceStackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.64),
            secondAndThirdPlaceStackView.heightAnchor.constraint(equalTo: firstPlaceView.heightAnchor, multiplier: 0.7),
            NSLayoutConstraint(item: secondAndThirdPlaceStackView, attribute: .top, relatedBy: .equal, toItem: firstPlaceView, attribute: .bottom, multiplier: 1.02, constant: 0),
            
            leaderBoard.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            leaderBoard.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.712468),
            leaderBoard.topAnchor.constraint(equalTo: secondAndThirdPlaceStackView.bottomAnchor, constant: 15),
            leaderBoard.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        ])
    }
    
    func configureLeaderboard() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(AwardTableViewCell.self, forCellReuseIdentifier: AwardTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
    }
    
    func configureTopThree() {
        guard let firstPlace = firstPlace, let secondPlace = secondPlace, let thirdPlace = thirdPlace else { return }
        firstPlaceImage.image = UIImage(named: firstPlace.iconName)
        firstPlaceTeamNum.text = "Team \(firstPlace.number)"
        firstPlaceTeamName.text = firstPlace.name
        firstPlacePoints.text = String(firstPlace.points)
        
        secondPlaceImage.image = UIImage(named: secondPlace.iconName)
        secondPlaceTeamNum.text = "Team \(secondPlace.number)"
        secondPlaceTeamName.text = secondPlace.name
        secondPlacePoints.text = String(secondPlace.points)
        
        thirdPlaceImage.image = UIImage(named: thirdPlace.iconName)
        thirdPlaceTeamNum.text = "Team \(thirdPlace.number)"
        thirdPlaceTeamName.text = thirdPlace.name
        thirdPlacePoints.text = String(thirdPlace.points)
    }
    
    func getNewTeamList(_ teamList: [Team]) -> [Team] {
        var i = 0
        var newList = teamList
        while (i <= 2) {
            newList.remove(at: 0)
            i += 1
        }
        let order: (Team, Team) -> Bool = {(lhs, rhs) in
            return lhs.points > rhs.points
        }
        newList.sort(by: order)
        return newList
    }
    
    @objc func callMainVC() {
        audioPlayerManager.stop()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let storyboardViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            self.navigationController?.pushViewController(storyboardViewController, animated: true)
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // Additional initialization if needed
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
// MARK: - teamList
extension AwardViewController: TeamList {
    func listOfTeams(_ teams: [Team]) {
        self.teamList = teams
        let order: (Team, Team) -> Bool = {(lhs, rhs) in
            return lhs.points > rhs.points
        }
        self.teamList.sort(by: order)
        leaderBoard.reloadData()
    }
}
// MARK: - tableView
extension AwardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: AwardTableViewCell.identifier, for: indexPath) as! AwardTableViewCell
        let teamNum = String(newTeamList[indexPath.section].number)
        cell.configureRankTableViewCell(imageName: newTeamList[indexPath.section].iconName, teamNum: "Team \(teamNum)", teamName: newTeamList[indexPath.section].name, points: newTeamList[indexPath.section].points)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return newTeamList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
