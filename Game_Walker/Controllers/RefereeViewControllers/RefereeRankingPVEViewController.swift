//
//  RefereeRankingPVEViewController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/30/23.
//

import Foundation
import UIKit

class RefereeRankingPVEViewController: UIViewController {
    
    @IBOutlet weak var leaderBoard: UITableView!
    
    private var teamList: [Team] = []
    
    static var localMessages: [Announcement] = []
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private var showScore = true
    
    private var isSeguePerformed = false
    private var timer = Timer()
    static var unread: Bool = false
    private var diff: Int?
    
    private let audioPlayerManager = AudioPlayerManager()
    
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationController?.isNavigationBarHidden = true
        configureTableView()
        configureNavigationBar()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            guard let items = strongSelf.navigationItem.rightBarButtonItems else { return }
            let unread = strongSelf.checkUnreadAnnouncements(announcements: RefereeRankingPVEViewController.localMessages)
            RefereeRankingPVEViewController.unread = unread
            if unread{
                NotificationCenter.default.post(name: .readNotification, object: nil, userInfo: ["unread":unread])
                for barButtonItem in items {
                    if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                        // 이미지 변경
                        btn.setImage(strongSelf.unreadSome, for: .normal)
                        break
                    }
                }
                NotificationCenter.default.post(name: .newDataNotif, object: nil)
            } else {
                NotificationCenter.default.post(name: .readNotification, object: nil, userInfo: ["unread":unread])
                for barButtonItem in items {
                    if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                        // 이미지 변경
                        btn.setImage(strongSelf.readAll, for: .normal)
                        break
                    }
                }
            }
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hostUpdate), name: .hostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(teamsUpdate), name: .teamsUpdate, object: nil)
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(RefereeTableViewCell.self, forCellReuseIdentifier: RefereeTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
    }
    
}
// MARK: - TableView
extension RefereeRankingPVEViewController: UITableViewDelegate, UITableViewDataSource {
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
extension RefereeRankingPVEViewController {
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
        print(componentFrames)
        print(componentPositions)
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor, explanationTexts, tabBarTop, "Ranking", "referee")
        
        present(overlayViewController, animated: true, completion: nil)
    }
}
// MARK: - @objc
extension RefereeRankingPVEViewController {
    
    @objc override func announceAction() {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.localMessages)
    }
    
    @objc override func infoAction() {
        self.showOverlay()
    }
    
    @objc func hostUpdate (notification: Notification) {
        guard let host = notification.userInfo?["host"] as? Host else { return }
        
        self.showScore = host.showScoreboard
        leaderBoard.reloadData()
        
        if RefereeRankingPVEViewController.localMessages.count > host.announcements.count {
            removeAnnouncementsNotInHost(from: &RefereeRankingPVEViewController.localMessages, targetArray: host.announcements)
            NotificationCenter.default.post(name: .newDataNotif, object: nil, userInfo: nil)
        } else {
            for announcement in host.announcements {
                let ids: [String] = RefereeRankingPVEViewController.localMessages.map({ $0.uuid })
                if !ids.contains(announcement.uuid) {
                    RefereeRankingPVEViewController.localMessages.append(announcement)
                    self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                    NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                } else {
                    if let localIndex = RefereeRankingPVEViewController.localMessages.firstIndex(where: {$0.uuid == announcement.uuid}) {
                        if RefereeRankingPVEViewController.localMessages[localIndex].content != announcement.content {
                            RefereeRankingPVEViewController.localMessages[localIndex].content = announcement.content
                            RefereeRankingPVEViewController.localMessages[localIndex].readStatus = false
                            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                            NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                        }
                    }
                }
            }
        }
    }
    
    @objc func teamsUpdate (notification: Notification) {
        guard var teams = notification.userInfo?["teams"] as? [Team] else { return }
        teams.sort { (team1, team2) -> Bool in
            if team1.points == team2.points {
                return team1.number < team2.number
            } else {
                return team1.points > team2.points
            }
        }
        self.teamList = teams
        if self.showScore {
            self.leaderBoard.reloadData()
        }
    }
}

