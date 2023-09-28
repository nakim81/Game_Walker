//
//  PlayerFrame4_2.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class RankingViewController: UIViewController {
    
    @IBOutlet weak var leaderBoard: UITableView!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    private var showScore: Bool = true
    private var teamList: [Team] = []
    private var selectedIndex: Int?
    
    private var currentPlayer: Player = UserData.readPlayer("player") ?? Player()
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    private let audioPlayerManager = AudioPlayerManager()
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 42)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = false
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureListeners()
        configureTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: TeamViewController.notificationName, object: nil)
        configureAlertIcon()
        configureGamecodeLabel()
    }
    
    private func configureListeners(){
        T.delegates.append(self)
        H.delegates.append(self)
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
    }
    
    private func configureGamecodeLabel() {
        view.addSubview(gameCodeLabel)
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (self.navigationController?.navigationBar.frame.minY)!),
        ])
    }
    
    @objc func readAll(notification: Notification) {
        guard let isRead = notification.userInfo?["isRead"] as? Bool else {
            return
        }
        if isRead {
            self.announcementButton.setImage(self.readAll, for: .normal)
        } else {
            self.announcementButton.setImage(self.unreadSome, for: .normal)
            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
        }
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showMessagePopUp(messages: TeamViewController.messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    private func configureAlertIcon() {
        if TeamViewController.read {
            self.announcementButton.setImage(readAll, for: .normal)
        } else {
            self.announcementButton.setImage(unreadSome, for: .normal)
        }
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
    }
}
// MARK: - tableView
extension RankingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
        let team = teamList[indexPath.row]
        let teamNum = String(team.number)
        let points = String(team.points)
        cell.configureRankTableViewCellWithScore(imageName: team.iconName, teamNum: "Team \(teamNum)", teamName: team.name, points: points, showScore: self.showScore)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamList.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
// MARK: - TeamProtocol
extension RankingViewController: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        self.teamList = teams
        if self.showScore {
            self.leaderBoard.reloadData()
        }
    }
}
// MARK: - HostProtocol
extension RankingViewController: HostUpdateListener {
    func updateHost(_ host: Host) {
        self.showScore = host.showScoreboard
        self.leaderBoard.reloadData()
    }
}
