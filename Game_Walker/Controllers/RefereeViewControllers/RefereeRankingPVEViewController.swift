//
//  RefereeRankingPVEViewController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/30/23.
//

import Foundation
import UIKit

class RefereeRankingPVEViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var leaderBoard: UITableView!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    private var messages: [String]?
    private var teamList: [Team] = []
    private var selectedIndex: Int?
    private let cellSpacingHeight: CGFloat = 3
    private var currentPlayer: Player = UserData.readPlayer("player") ?? Player()
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegate_teamList = self
        H.delegate_getHost = self
        configureTableView()
        T.getTeamList(gameCode)
        H.getHost(gameCode)
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showMessagePopUp(messages: ["Hi", "Hello", "How are you"])
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(RefereeTeamTableViewCell.self, forCellReuseIdentifier: RefereeTeamTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
        leaderBoard.refreshControl = refreshController
        settingRefreshControl()
    }
    
    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1)
        refreshController.attributedTitle = NSAttributedString(string: "reloading,,,", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1) , NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
    
    @objc func refreshFunction() {
        T.getTeamList(gameCode)
        refreshController.endRefreshing()
        leaderBoard.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: RefereeTeamTableViewCell.identifier, for: indexPath) as! RefereeTeamTableViewCell
        cell.configureRankTableViewCell(imageName: teamList[indexPath.section].iconName, teamName: teamList[indexPath.section].name, points: teamList[indexPath.section].points)
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
extension RefereeRankingPVEViewController: TeamList, GetHost {
    func listOfTeams(_ teams: [Team]) {
        self.teamList = teams
        leaderBoard.reloadData()
    }
    
    func getHost(_ host: Host) {
        self.messages = host.announcements
    }
}
