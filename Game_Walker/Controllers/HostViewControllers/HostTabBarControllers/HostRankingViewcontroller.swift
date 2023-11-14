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
    @IBOutlet weak var rankingLbl: UILabel!
    
    static var messages: [Announcement] = []
    private var teamList: [Team] = []
    private var selectedIndex: Int?
    private let cellSpacingHeight: CGFloat = 1
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let standardStyle = UserData.isStandardStyle() ?? true
    
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private var showScore = true
    private var round: Int = 0
    private var algorithm: [[Int]] = [[]]
    private var stationList: [Station] = []
    
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
        super.viewWillAppear(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if standardStyle {
            getAlgorithmAndStation()
        } else {
            configureTableView()
        }
        setDelegates()
        setMessages()
        configureGamecodeLabel()
        Task { @MainActor in
            let host = try await H.getHost(gameCode)
            switchBtn.isOn = host?.showScoreboard ?? true
        }
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
    
    private func getAlgorithmAndStation() {
        Task {@MainActor in
            do {
                self.stationList = try await S.getStationList(gameCode)
                let host = try await H.getHost(gameCode)
                guard let h = host else {return}
                let temp = h.algorithm
                self.algorithm = convert1DArrayTo2D(temp)
                self.round = h.currentRound - 1
                print(self.algorithm)
                print(self.round)
                configureTableView()
            } catch GameWalkerError.serverError(let text) {
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
        H.delegates.append(self)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
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
// MARK: - Gamecode Label
extension HostRankingViewcontroller {
    
    private func configureGamecodeLabel() {
        rankingLbl.font = UIFont(name: "GemunuLibre-SemiBold", size: fontSize(size: 50))
        view.addSubview(gameCodeLabel)
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.centerYAnchor.constraint(equalTo: announcementBtn.centerYAnchor),
        ])
    }
}
// MARK: - HostRankingGuidView
extension HostRankingViewcontroller {
    private func showOverlay() {
        let overlayViewController = RorTOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = ["Ranking Status", "Timer & Start/End Game", "Click to hide points from others"]
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
        let teamNum = teamList[indexPath.row].number
        let team = teamList[indexPath.row]
        var stationName: String
        if self.standardStyle {
            stationName = self.findStation(self.round, teamNum)
        } else {
            stationName = ""
        }
        cell.configureRankTableViewCell(imageName: team.iconName, teamNum: "Team \(teamNum)", teamName: team.name, stationName: stationName, points: team.points, showScore: self.showScore)
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
    
    private func findStation( _ round: Int, _ teamNum: Int) -> String {
        guard round >= 0, round < self.algorithm.count else {
            return "Invalid round"
        }
        
        let currentRound = self.algorithm[round]
        print(teamNum)
        print(currentRound)
        if let teamIndex = currentRound.firstIndex(of: teamNum) {
            print(teamIndex)
            let numberOfPVP = findNumberOfPVP(self.stationList)
            
            if numberOfPVP == 0 {
                return stationList[teamIndex].name
            } else {
                let limit = numberOfPVP * 2
                if teamIndex < limit {
                    return stationList[teamIndex / 2].name
                } else {
                    return stationList[teamIndex - numberOfPVP].name
                }
            }
        } else {
            return "currently not playing"
        }
    }
}

// MARK: - TeamProtocol
extension HostRankingViewcontroller: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        self.teamList = teams
        self.teamList.sort { (team1, team2) in
            if team1.points != team2.points {
                return team1.points > team2.points
            } else {
                return team1.number < team2.number
            }
        }
        leaderBoard.reloadData()
    }
}
// MARK: - HostProtocol
extension HostRankingViewcontroller: HostUpdateListener {
    func updateHost(_ host: Host) {
        self.round = host.currentRound - 1
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
