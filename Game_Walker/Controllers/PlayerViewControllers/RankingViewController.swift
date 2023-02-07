//
//  PlayerFrame4_2.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var leaderBoard: UITableView!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    private var teamList: [Team] = []
    private var selectedIndex: Int?
    private let cellSpacingHeight: CGFloat = 3
    private var currentPlayer: Player = UserData.readPlayer("player") ?? Player()
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegates.append(self)
        H.delegates.append(self)
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        configureTableView()
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showMessagePopUp(messages: TeamViewController.messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
        let teamNum = String(teamList[indexPath.section].number)
        cell.configureRankTableViewCell(imageName: teamList[indexPath.section].iconName, teamNum: "Team \(teamNum)", teamName: teamList[indexPath.section].name, points: teamList[indexPath.section].points)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return teamList.count
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
// MARK: - TeamProtocol
extension RankingViewController: TeamUpdateListener, HostUpdateListener {
    func updateHost(_ host: Host) {
        TeamViewController.messages = host.announcements
        if TeamViewController.messages?.count != TeamViewController.selectedIndexList.count {
            announcementButton.setImage(unreadSome, for: .normal)
        } else {
            announcementButton.setImage(readAll, for: .normal)
        }
    }
    
    func updateTeams(_ teams: [Team]) {
        self.teamList = teams
        leaderBoard.reloadData()
    }
}
