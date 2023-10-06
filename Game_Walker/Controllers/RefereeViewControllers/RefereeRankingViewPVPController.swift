//
//  RefereeRankingViewPVPController.swift
//  Game_Walker
//
//  Created by 김현식 on 2/13/23.
//

import Foundation
import UIKit

class RefereeRankingPVPViewController: UIViewController {
    
    @IBOutlet weak var leaderBoard: UITableView!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    private var teamList: [Team] = []
    private let cellSpacingHeight: CGFloat = 1
    private var currentPlayer: Player = UserData.readPlayer("player") ?? Player()
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private var showScore = true
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    private let audioPlayerManager = AudioPlayerManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: RefereeRankingPVEViewController.notificationName, object: nil)
        if RefereeRankingPVEViewController.unread {
            self.announcementButton.setImage(unreadSome, for: .normal)
            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
        } else {
            self.announcementButton.setImage(readAll, for: .normal)
        }
    }
    
    @objc func readAll(notification: Notification) {
        guard let unread = notification.userInfo?["unread"] as? Bool else {
            return
        }
        if unread {
            self.announcementButton.setImage(self.unreadSome, for: .normal)
            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
        } else {
            self.announcementButton.setImage(self.readAll, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        T.delegates.append(self)
        H.delegates.append(self)
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.localMessages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(RefereeTableViewCell.self, forCellReuseIdentifier: RefereeTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
    }
    
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
    
    private func configureGamecodeLabel() {
        view.addSubview(gameCodeLabel)
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (self.navigationController?.navigationBar.frame.minY)!)
        ])
    }
    
    func listen(_ _ : [String : Any]){
    }
}
// MARK: - TableView
extension RefereeRankingPVPViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: RefereeTableViewCell.identifier, for: indexPath) as! RefereeTableViewCell
        let team = teamList[indexPath.row]
        let teamNum = String(team.number)
        let points = String(team.points)
        cell.configureRankTableViewCell(imageName: team.iconName, teamNum: "Team \(teamNum)", teamName: team.name, points: points, showScore: self.showScore)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamList.count
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
}
// MARK: - TeamProtocol
extension RefereeRankingPVPViewController: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        self.teamList = teams
        if self.showScore{
            leaderBoard.reloadData()
        }
    }
}
// MARK: - HostProtocl
extension RefereeRankingPVPViewController: HostUpdateListener {
    func updateHost(_ host: Host) {
        self.showScore = host.showScoreboard
        leaderBoard.reloadData()
    }
}

