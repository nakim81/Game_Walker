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
    @IBOutlet weak var infoButton: UIButton!
    
    private var teamList: [Team] = []
    
    static var localMessages: [Announcement] = []
    static var unread: Bool = false
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private var showScore = true
    
    private var timer = Timer()
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    private let audioPlayerManager = AudioPlayerManager()
    private var awardViewControllerPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureListeners()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            let unread = strongSelf.checkUnreadAnnouncements(announcements: RefereeRankingPVPViewController.localMessages)
            RefereeRankingPVPViewController.unread = unread
            if unread{
                NotificationCenter.default.post(name: .readNotification, object: nil, userInfo: ["unread":unread])
                strongSelf.announcementButton.setImage(strongSelf.unreadSome, for: .normal)
                NotificationCenter.default.post(name: .newDataNotif, object: nil)
            } else {
                NotificationCenter.default.post(name: .readNotification, object: nil, userInfo: ["unread":unread])
                strongSelf.announcementButton.setImage(strongSelf.readAll, for: .normal)
            }
        }
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showRefereeMessagePopUp(messages: RefereeRankingPVPViewController.localMessages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        self.showOverlay()
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(RefereeTableViewCell.self, forCellReuseIdentifier: RefereeTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
    }
    
    private func configureListeners(){
        T.delegates.append(WeakTeamUpdateListener(value: self))
        H.delegates.append(WeakHostUpdateListener(value: self))
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
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
            gameCodeLabel.centerYAnchor.constraint(equalTo: announcementButton.centerYAnchor),
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
// MARK: - overlay guide
extension RefereeRankingPVPViewController {
    private func showOverlay() {
        let overlayViewController = RorTOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = ["Station Status", "Ranking Status", "Timer & Station Info", "Points can be hidden by the Host"]
        var componentPositions: [CGPoint] = []
        var componentFrames: [CGRect] = []
        let component1Frame = CGRect(x: Int(self.leaderBoard.frame.maxX - 85), y: Int(self.leaderBoard.frame.minY + 42.5), width: 85, height: 17)
        var tabBarTop: CGFloat = 0
        if let tabBarController = self.tabBarController {
            // Loop through each view controller in the tab bar controller
            for viewController in tabBarController.viewControllers ?? [] {
                if let tabItem = viewController.tabBarItem {
                    // Access the tab bar item of the current view controller
                    if let tabItemView = tabItem.value(forKey: "view") as? UIView {
                        let tabItemFrame = tabItemView.frame
                        // Calculate centerX position
                        let centerXPosition = tabItemFrame.midX
                        // Calculate topAnchor position based on tab bar's frame
                        let tabBarFrame = tabBarController.tabBar.frame
                        let topAnchorPosition = tabItemFrame.minY + tabBarFrame.origin.y
                        tabBarTop = tabBarFrame.minY
                        componentFrames.append(tabItemFrame)
                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
                    }
                }
            }
        }
        componentFrames.append(component1Frame)
        print(componentPositions)
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor, explanationTexts, tabBarTop, "Ranking", "referee")
        
        present(overlayViewController, animated: true, completion: nil)
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
        if host.gameover && !awardViewControllerPresented {
            showAwardPopUp()
            self.awardViewControllerPresented = true
            return
        }
        self.showScore = host.showScoreboard
        leaderBoard.reloadData()
        var hostAnnouncements = Array(host.announcements)
        if RefereeRankingPVPViewController.localMessages.count > hostAnnouncements.count {
            removeAnnouncementsNotInHost(from: &RefereeRankingPVPViewController.localMessages, targetArray: hostAnnouncements)
            NotificationCenter.default.post(name: .newDataNotif, object: nil, userInfo: nil)
        } else {
            for announcement in hostAnnouncements {
                if !RefereeRankingPVPViewController.localMessages.contains(announcement) {
                    RefereeRankingPVPViewController.localMessages.append(announcement)
                    self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                    NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                } else {
                    if let localIndex = RefereeRankingPVPViewController.localMessages.firstIndex(where: {$0.uuid == announcement.uuid}) {
                        if RefereeRankingPVPViewController.localMessages[localIndex].content != announcement.content {
                            RefereeRankingPVPViewController.localMessages[localIndex].content = announcement.content
                            RefereeRankingPVPViewController.localMessages[localIndex].readStatus = false
                            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                            NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                        }
                    }
                }
            }
        }
    }
}

