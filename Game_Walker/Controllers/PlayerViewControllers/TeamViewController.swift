//
//  PlayerFrame4_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class TeamViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    static var selectedIndexList: [IndexPath] = []
    static var selectedIntList: [Int] = []
    static var messages: [String]?
    private var team: Team?
    private let cellSpacingHeight: CGFloat = 3
    private var currentPlayer = UserData.readPlayer("player") ?? Player()
    private var gameCode = UserData.readGamecode("gamecode") ?? ""
    private var teamName = UserData.readTeam("team")?.name ?? ""
    private let refreshController : UIRefreshControl = UIRefreshControl()
    
    private var timer = Timer()
    static var read: Bool = true
    private var diff: Int?
    
    static let notificationName = Notification.Name("readNotification")
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegate_getTeam = self
        H.delegates.append(self)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        configureTableView()
        T.getTeam(gameCode, teamName)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            strongSelf.diff = (TeamViewController.messages?.count ?? 0) - TeamViewController.selectedIndexList.count
            if strongSelf.diff! < 1 {
                if TeamViewController.read == false {
                    TeamViewController.read = true
                    NotificationCenter.default.post(name: TeamViewController.notificationName, object: nil, userInfo: ["isRead": TeamViewController.read])
                    strongSelf.announcementButton.setImage(strongSelf.readAll, for: .normal)
                }
            } else {
                if TeamViewController.read == true {
                    TeamViewController.read = false
                    NotificationCenter.default.post(name: TeamViewController.notificationName, object: nil, userInfo: ["isRead": TeamViewController.read])
                    strongSelf.announcementButton.setImage(strongSelf.unreadSome, for: .normal)
                }
            }
        }
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    private func configureTableView() {
        table.delegate = self
        table.dataSource = self
        table.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        table.backgroundColor = .clear
        table.allowsSelection = false
        table.separatorStyle = .none
        table.refreshControl = refreshController
        settingRefreshControl()
    }
    @IBAction func leaveButtonPressed(_ sender: UIButton) {
        alert(title: "", message: "Do you really want to leave your team?", sender: sender)
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        print(TeamViewController.selectedIntList)
        print(TeamViewController.selectedIndexList)
        print(TeamViewController.messages?.indices)
        showMessagePopUp(messages: TeamViewController.messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func alert(title: String, message: String, sender: UIButton) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Leave", style: .destructive, handler: { [self]action in
            T.leaveTeam(self.gameCode, self.teamName, self.currentPlayer)
            self.performSegue(withIdentifier: "returntoCorJ", sender: sender)
        })
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Stay", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
        refreshController.attributedTitle = NSAttributedString(string: "reloading,,,", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1) , NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
    
    @objc func refreshFunction() {
        T.getTeam(gameCode, teamName)
        refreshController.endRefreshing()
        table.reloadData()
    }
}
// MARK: - TableView
extension TeamViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
        cell.configureTeamTableViewCell(name: team!.players[indexPath.section].name)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let team = team else {
            return 0
        }
        return team.players.count
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
extension TeamViewController: GetTeam, HostUpdateListener {
    func updateHost(_ host: Host) {
        if (TeamViewController.messages?.count ?? 0 > host.announcements.count) {
//            var count = 0
//            if let messages = TeamViewController.messages {
//                for ind in messages.indices {
//                    if (ind - count >= host.announcements.count) {
//                      break;
//                    }
//                    if (messages[ind] != host.announcements[ind - count]) {
//                        if let index = TeamViewController.selectedIntList.firstIndex(of: ind) {
//                            TeamViewController.selectedIntList.remove(at: index)
//                            TeamViewController.selectedIndexList.remove(at: index)
//                        }
//                        count += 1
//                    }
//                }
//            }
            TeamViewController.messages = host.announcements
            table.reloadData()
        } else {
            TeamViewController.messages = host.announcements
        }
    }
    
    func getTeam(_ team: Team) {
        self.team = team
        table.reloadData()
    }
}



