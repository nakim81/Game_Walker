//
//  HostRankingViewcontroller.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/1/23.
//

import Foundation
import UIKit

class HostRankingViewcontroller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var leaderBoard: UITableView!
    private var messages: [String]?
    private var teamList: [Team] = []
    private var selectedIndex: Int?
    private let cellSpacingHeight: CGFloat = 3
    private var gameCode: String = UserData.readGamecode("gamecodestring") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegates.append(self)
        H.delegate_getHost = self
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        configureTableView()
        H.getHost(gameCode)
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        H.getHost(gameCode)
        showMessagePopUp(messages: messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(HostRankingTableViewCell.self, forCellReuseIdentifier: HostRankingTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: HostRankingTableViewCell.identifier, for: indexPath) as! HostRankingTableViewCell
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
extension HostRankingViewcontroller: TeamUpdateListener, GetHost {
    func updateTeams(_ teams: [Team]) {
        self.teamList = teams
        leaderBoard.reloadData()
    }
    
    func getHost(_ host: Host) {
        self.messages = host.announcements
    }
}
