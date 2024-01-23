//
//  PlayerFrame4_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class PlayerTeamViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var teamNumLbl: UILabel!
    @IBOutlet weak var teamNameLbl: UILabel!
    
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    private var team: Team?
    private var currentPlayer = UserData.readPlayer("player") ?? Player()
    private var gameCode = UserData.readGamecode("gamecode") ?? ""
    private var teamName = UserData.readTeam("team")?.name ?? ""
    private let refreshController : UIRefreshControl = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: .readNotification, object: nil)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureLeaveBtn()
        configureTableView()
        configureLabel()
        tabBarController?.navigationController?.isNavigationBarHidden = true
    }
    
    func configureLeaveBtn() {
        let leaveBtn = UIButton()
        leaveBtn.setTitle(NSLocalizedString("LEAVE", comment: ""), for: .normal)
        leaveBtn.titleLabel?.font = UIFont(name: "GemunuLibre-Bold", size: 25)
        leaveBtn.setTitleColor(UIColor(red: 1, green: 0.046, blue: 0.046, alpha: 1), for: .normal)
        leaveBtn.addTarget(self, action: #selector(customBackAction(_:)), for: .touchUpInside)
        let leave = UIBarButtonItem(customView: leaveBtn)
        self.navigationItem.leftBarButtonItem = leave
    }
    
    private func configureLabel(){
        let team = UserData.readTeam("team") ?? Team()
        
        teamNumLbl.text = "TEAM \(String(describing: team.number))"
        teamNumLbl.font = UIFont(name: "GemunuLibre-Regular", size: fontSize(size: 40))
        teamNameLbl.text = team.name
        teamNameLbl.font = UIFont(name: "GemunuLibre-Regular", size: fontSize(size: 30))
    }
    
    private func configureTableView() {
        table.delegate = self
        table.dataSource = self
        table.register(PlayerTableViewCell.self, forCellReuseIdentifier: PlayerTableViewCell.identifier)
        table.backgroundColor = .clear
        table.allowsSelection = false
        table.separatorStyle = .none
        table.refreshControl = refreshController
        settingRefreshControl()
        Task { @MainActor in
            do {
                self.team = try await T.getTeam(gameCode, teamName)
                table.reloadData()
            } catch {
                alert(title: NSLocalizedString("Connection Error", comment: ""), message: NSLocalizedString("Swipe down your screen to see your team members.", comment: ""))

            }
        }
    }
    
    private func alert2(title: String, message: String, sender: AnyObject) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Leave!", style: .destructive, handler: { [self]action in
            Task { @MainActor in
                do {
                    try await T.leaveTeam(self.gameCode, self.teamName, self.currentPlayer)
                    if let team = self.team {
                        if (team.players.count == 1) {
                            T.removeTeam(gameCode, team)
                        }
                    }
                    UserData.clearMyTeam("team")
                    self.performSegue(withIdentifier: "unwindToCorJ", sender: sender)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
            }
        })
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Stay!", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
        refreshController.attributedTitle = NSAttributedString(string: "reloading,,,", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1) , NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
}
// MARK: - TableView
extension PlayerTeamViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: PlayerTableViewCell.identifier, for: indexPath) as! PlayerTableViewCell
        cell.configureTeamTableViewCell(name: team!.players[indexPath.row].name)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let team = team else {
            return 0
        }
        return team.players.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            // Return the height of the cell plus the spacing.
            return 65
        }
}
// MARK: - overlay guide
extension PlayerTeamViewController {
    private func showOverlay() {
        let overlayViewController = RorTOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = [
            NSLocalizedString("Team\nMembers", comment: ""),
            NSLocalizedString("Ranking\nStatus", comment: ""),
            NSLocalizedString("Timer &\nStation Info", comment: "")
        ]

        var componentPositions: [CGPoint] = []
        var componentFrames: [CGRect] = []
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
        print(componentPositions)
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor, explanationTexts, tabBarTop, "Team", "player")
        
        present(overlayViewController, animated: true, completion: nil)
    }
}
// MARK: - @objc
extension PlayerTeamViewController {
    
    @objc func customBackAction(_ sender: UIBarButtonItem) {
        self.alert2(title: NSLocalizedString("", comment: ""), message: NSLocalizedString("Do you really want to leave your team?", comment: ""), sender: sender)

    }
    
    @objc override func infoAction() {
        self.showOverlay()
    }
    
    @objc override func announceAction() {
        showMessagePopUp(messages: PlayerTabBarController.localMessages, role: "player")
    }
    
    @objc func refreshFunction() {
        Task { @MainActor in
            do {
                self.team = try await T.getTeam(gameCode, teamName)
                refreshController.endRefreshing()
                table.reloadData()
            } catch {
                alert(title: NSLocalizedString("Connection Error", comment: ""), message: NSLocalizedString("Swipe down your screen to see your team members.", comment: ""))

            }
        }
    }
    
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
}


