//
//  HostRankingViewcontroller.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/1/23.
//

import Foundation
import UIKit

class HostRankingViewcontroller: UIViewController {
    
    @IBOutlet weak var leaderBoard: UITableView!
    @IBOutlet weak var announcementBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var switchBtn: CustomSwitchButton!
    @IBOutlet weak var infoBtn: UIButton!
    
    static var messages: [Announcement] = []
    private var teamList: [Team] = []
    private var selectedIndex: Int?
    private let cellSpacingHeight: CGFloat = 1
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private var showScore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        configureTableView()
        setMessages()
        print(switchBtn.frame)
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showHostMessagePopUp(messages: HostRankingViewcontroller.messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func switchBtnPressed(_ sender: CustomSwitchButton) {
        //Update showScoreBoard of host on the server
    }
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        self.showOverlay()
    }
    
    private func setMessages() {
        Task {@MainActor in
            do {
                HostRankingViewcontroller.messages = try await H.getHost(gameCode)!.announcements
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
        }
    }
    
    private func setDelegates() {
        T.delegates.append(self)
        switchBtn.delegate = self
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        self.showScore = switchBtn.isOn
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(HostRankingTableViewCell.self, forCellReuseIdentifier: HostRankingTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = true
        leaderBoard.separatorStyle = .none
        leaderBoard.allowsMultipleSelection = false
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        showOverlay()
    }
    
}
// MARK: - HostRankingGuidView
extension HostRankingViewcontroller {
    private func showOverlay() {
        let overlayViewController = RorTOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = ["Ranking Status", "Timer & Start/End Game", "Click to hide points from otherst"]
        var componentPositions: [CGPoint] = []
        var componentFrames: [CGRect] = []
        let component1Frame = CGRect(x: self.leaderBoard.frame.maxX - 85.0, y: self.leaderBoard.frame.minY, width: self.leaderBoard.frame.width, height: 17)
        let component2Frame = CGRect(x: self.switchBtn.frame.minX, y: self.switchBtn.frame.minY, width: self.switchBtn.frame.width, height: self.switchBtn.frame.height)
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
        componentFrames.append(component2Frame)
        componentPositions.append(CGPoint(x: leaderBoard.frame.maxX, y: leaderBoard.frame.minY))
        componentPositions.append(CGPoint(x: switchBtn.frame.minX, y: switchBtn.frame.minY))
        print(componentPositions)
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor, explanationTexts, tabBarTop, "Ranking", "host")

        present(overlayViewController, animated: true, completion: nil)
    }
}
// MARK: - tableView
extension HostRankingViewcontroller: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: HostRankingTableViewCell.identifier, for: indexPath) as! HostRankingTableViewCell
        let teamNum = String(teamList[indexPath.row].number)
        let team = teamList[indexPath.row]
        //comeback later: stationName
        cell.configureRankTableViewCell(imageName: team.iconName, teamNum: "Team \(teamNum)", teamName: team.name, stationName: "team.currentStation", points: team.points, showScore: self.showScore)
        cell.selectionStyle = .none
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        let team = teamList[indexPath.row]
        let svc = HostGivePointsController(team: team, gameCode: self.gameCode)
        svc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(svc, animated: true)
        leaderBoard.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - TeamProtocol
extension HostRankingViewcontroller: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        self.teamList = teams
        leaderBoard.reloadData()
    }
}
// MARK: - SwitchBtn
extension HostRankingViewcontroller: CustomSwitchButtonDelegate {
  func isOnValueChange(isOn: Bool) {
      self.showScore = isOn
      Task { @MainActor in
          do {
              try await H.hide_show_score(gameCode, self.showScore)
              leaderBoard.reloadData()
          } catch GameWalkerError.serverError(let text){
              print(text)
              serverAlert(text)
              return
          }
      }
  }
}
// MARK: - ModalViewControllerDelegate
extension HostRankingViewcontroller: ModalViewControllerDelegate {
    func modalViewControllerDidRequestPush() {
        self.showAwardPopUp()
    }
}
