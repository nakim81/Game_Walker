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
    @IBOutlet weak var endGameBtn: UIButton!
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
    
    @IBAction func endGameBtnPressed(_ sender: UIButton) {
        //present end game warning popup
//        showEndGamePopUp(announcement: "Do you really want to end this game?", source: "", gamecode: gameCode)
        let endGamePopUp = EndGameViewController(announcement: "Do you really want to end this game?", source: "", gamecode: gameCode)
        endGamePopUp.delegate = self
        present(endGamePopUp, animated: true)
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
    
    // MARK: - Overlay
    @IBAction func infoButtonPressed(_ sender: Any) {
//        view.addSubview(shadeView)
//        view.addSubview(arrowView)
//        view.addSubview(closeBtn)
//        view.addSubview(switchBtn)
//        switchBtn.isUserInteractionEnabled = false
//        view.addSubview(explanationLabel)
        showOverlay()
//        setupOverlayView()
    }
    
//    private lazy var shadeView: UIView = {
//        var view = UIView(frame: view.bounds)
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        return view
//    }()
//
//    private lazy var arrowView: UIImageView = {
//        var view = UIImageView()
//        view.image = UIImage(named: "Arrow")
//        return view
//    }()
//
//    private lazy var closeBtn: UIImageView = {
//        var view = UIImageView()
//        view.image = UIImage(named: "icon _close_")
//        view.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
//        view.addGestureRecognizer(tapGesture)
//        return view
//    }()
//
//    private lazy var explanationLabel: UILabel = {
//        var label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Click to hide points from others"
//        label.textColor = .white
//        label.textAlignment = .center
//        label.font = UIFont(name: "Dosis-Bold", size: 13)
//        return label
//    }()
//
//    private func setupOverlayView() {
//        closeBtn.translatesAutoresizingMaskIntoConstraints = false
//        arrowView.translatesAutoresizingMaskIntoConstraints = false
//        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            closeBtn.widthAnchor.constraint(equalToConstant: 44),
//            closeBtn.heightAnchor.constraint(equalToConstant: 44),
//            closeBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25),
//            closeBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
//
//            explanationLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
//            explanationLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier:0.0604),
//            explanationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            explanationLabel.topAnchor.constraint(equalTo: switchBtn.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
//
//            arrowView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.35),
//            arrowView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.12),
//            arrowView.bottomAnchor.constraint(equalTo: explanationLabel.topAnchor, constant: UIScreen.main.bounds.size.height * 0.005),
//            arrowView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
//        ])
//    }
//
//    @objc func dismissOverlay() {
//        shadeView.removeFromSuperview()
//        closeBtn.removeFromSuperview()
//        explanationLabel.removeFromSuperview()
//        switchBtn.isUserInteractionEnabled = true
//        for border in circularBorders {
//            border.removeFromSuperview()
//        }
//        for label in explanationLbls {
//            label.removeFromSuperview()
//        }
//        explanationLbls.removeAll()
//        circularBorders.removeAll()
//    }
//
//    var circularBorders: [UIView] = []
//    var explanationLbls: [UILabel] = []
//
//    private func showOverlay() {
//        var index : Int = 0
//        var tabBarTop: CGFloat = 0
//        var componentPositions: [CGPoint] = []
//        let explanationTexts = ["Ranking Status", "Timer & Start/End Game"]
//        let colors = [UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor, UIColor(red:0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor]
//        if let tabBarController = self.tabBarController {
//            for viewController in tabBarController.viewControllers ?? [] {
//                if let tabItem = viewController.tabBarItem {
//                    if let tabItemView = tabItem.value(forKey: "view") as? UIView {
//                        // Adding Circle Borders on Tab Bar Frame
//                        let tabItemFrame = tabItemView.frame
//                        let tabBarFrame = tabBarController.tabBar.frame
//                        let centerXPosition = tabItemFrame.midX
//                        let centerYPosition = tabBarFrame.midY
//                        let circularBorder = UIView()
//                        circularBorder.frame = CGRect(x: centerXPosition / 2, y: centerYPosition / 2,width: tabItemFrame.width * 0.33, height: tabItemFrame.width * 0.33)
//                        circularBorder.layer.cornerRadius = tabItemFrame.width * 0.35 / 2
//                        circularBorder.layer.borderWidth = 4.0
//                        circularBorder.layer.borderColor = colors[index]
//                        circularBorder.translatesAutoresizingMaskIntoConstraints = false
//                        self.view.addSubview(circularBorder)
//                        circularBorders.append(circularBorder)
//                        // Adding Texts on Tab Bar Frame
//                        let topAnchorPosition = tabItemFrame.minY + tabBarFrame.origin.y
//                        if (tabBarTop == 0) {
//                            tabBarTop = topAnchorPosition
//                        }
//                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
//                        NSLayoutConstraint.activate([
//                            circularBorder.centerXAnchor.constraint(equalTo: tabItemView.centerXAnchor),
//                            circularBorder.centerYAnchor.constraint(equalTo: tabItemView.centerYAnchor),
//                            circularBorder.widthAnchor.constraint(equalTo: tabItemView.widthAnchor,multiplier: 0.33),
//                                circularBorder.heightAnchor.constraint(equalTo: tabItemView.widthAnchor, multiplier: 0.33)
//                        ])
//
//                        let explanationLbl = UILabel()
//                        explanationLbl.translatesAutoresizingMaskIntoConstraints = false
//                        explanationLbl.text = explanationTexts[index]
//                        explanationLbl.numberOfLines = 0
//                        explanationLbl.textAlignment = .center
//                        explanationLbl.textColor = .white
//                        explanationLbl.font = UIFont(name: "Dosis-Bold", size: 15)
//                        explanationLbls.append(explanationLbl)
//                        self.view.addSubview(explanationLbl)
//                        var maxWidth: CGFloat = 0
//                        if (componentPositions[index].y >= tabBarTop) {
//                            maxWidth = 75
//                        } else {
//                            maxWidth = 200
//                        }
//                        explanationLbl.widthAnchor.constraint(lessThanOrEqualToConstant:maxWidth).isActive = true
//                        NSLayoutConstraint.activate([
//                            explanationLbl.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: componentPositions[index].x),
//                                explanationLbl.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: componentPositions[index].y - 15)
//                        ])
//                        index += 1
//                    }
//                }
//            }
//        }
//    }
    
    
    private func showOverlay() {
        let overlayViewController = HostRankingGuideViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay

        let explanationTexts = ["Ranking Status", "Timer & Station Info"]
        var componentPositions: [CGPoint] = []
        var componentFrames: [CGRect] = []
        let component1Frame = CGRect(x: Int(self.switchBtn.frame.maxX - 60), y: Int(self.switchBtn.frame.minY + 17.5), width: 60, height: 31)
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
        //overlayViewController.setupOverlayView(_button: switchBtn)
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor.black.cgColor, explanationTexts, tabBarTop)

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
          } catch GameWalkerError.serverError(let text){
              print(text)
              serverAlert(text)
              return
          }
      }
      leaderBoard.reloadData()
  }
}
// MARK: - ModalViewControllerDelegate
extension HostRankingViewcontroller: ModalViewControllerDelegate {
    func modalViewControllerDidRequestPush() {
        self.showAwardPopUp()
    }
}
