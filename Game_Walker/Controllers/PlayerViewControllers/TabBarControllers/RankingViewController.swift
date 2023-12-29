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
    @IBOutlet weak var rankingLbl: UILabel!
    
    private var showScore: Bool = true
    private var teamList: [Team] = []
    private var selectedIndex: Int?
    
    private var currentPlayer: Player = UserData.readPlayer("player") ?? Player()
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        if PlayerTabBarController.unread {
            if let items = self.navigationItem.rightBarButtonItems {
                for barButtonItem in items {
                    if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                        // 이미지 변경
                        btn.setImage(self.unreadSome, for: .normal)
                        break
                    }
                }
            }
        } else {
            if let items = self.navigationItem.rightBarButtonItems {
                for barButtonItem in items {
                    if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                        // 이미지 변경
                        btn.setImage(self.readAll, for: .normal)
                        break
                    }
                }
            }
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: .readNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOrHideScore), name: .hostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLeaderboard), name: .teamsUpdate, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationController?.isNavigationBarHidden = true
        configureNavigationBar()
        configureTableView()
        Task{@MainActor in
            do {
                teamList = try await T.getTeamList(gameCode)
                guard let host = try await H.getHost(gameCode) else { return }
                showScore = host.showScoreboard
                leaderBoard.reloadData()
            } catch GameWalkerError.serverError(let message) {
                print(message)
                serverAlert(message)
                return
            }
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
// MARK: - overlay guide
extension RankingViewController {
    private func showOverlay() {
        let overlayViewController = RorTOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = [
            NSLocalizedString("Team Members", comment: ""),
            NSLocalizedString("Ranking Status", comment: ""),
            NSLocalizedString("Timer & Station Info", comment: ""),
            NSLocalizedString("Points can be hidden", comment: "")
        ]

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
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor, explanationTexts, tabBarTop, "Ranking", "player")
        
        present(overlayViewController, animated: true, completion: nil)
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
        return fontSize(size: 85)
    }
}
// MARK: - @objc
extension RankingViewController {
    
    @objc func readAll(notification: Notification) {
        guard let unread = notification.userInfo?["unread"] as? Bool else {
            return
        }
        if unread {
            if let items = self.navigationItem.rightBarButtonItems {
                for barButtonItem in items {
                    if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                        // 이미지 변경
                        btn.setImage(self.unreadSome, for: .normal)
                        break
                    }
                }
            }
        } else {
            if let items = self.navigationItem.rightBarButtonItems {
                for barButtonItem in items {
                    if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                        // 이미지 변경
                        btn.setImage(self.readAll, for: .normal)
                        break
                    }
                }
            }
        }
    }
    
    @objc override func announceAction() {
        showMessagePopUp(messages: PlayerTabBarController.localMessages)
    }
    
    @objc override func infoAction() {
        self.showOverlay()
    }
    
    @objc override func settingApp() {
        
    }
    
    @objc func showOrHideScore(notification: Notification) {
        guard let host = notification.userInfo?["host"] as? Host else {return}
        self.showScore = host.showScoreboard
        if showScore {
            Task {@MainActor in
                do {
                    self.teamList = try await T.getTeamList(gameCode)
                    self.leaderBoard.reloadData()
                } catch GameWalkerError.serverError(let e) {
                    print(e)
                    serverAlert(e)
                    return
                }
            }
        } else {
            self.leaderBoard.reloadData()
        }
    }
    
    @objc func updateLeaderboard(notification: Notification) {
        guard var teams = notification.userInfo?["teams"] as? [Team] else { return }
        teams.sort { (team1, team2) -> Bool in
            if team1.points == team2.points {
                return team1.number < team2.number
            } else {
                return team1.points > team2.points
            }
        }
        if self.showScore {
            self.teamList = teams
            self.leaderBoard.reloadData()
        }
    }
}
