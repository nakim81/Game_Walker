//
//  PlayerFrame4_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class TeamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var leaveButton: UIButton!
    private var team: Team?
    private let cellSpacingHeight: CGFloat = 3
    private var currentPlayer = UserData.readPlayer("player") ?? Player()
    private var gameCode = UserData.readGamecode("gamecode") ?? ""
    private var teamName = UserData.readTeam("team")?.name ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegate_getTeam = self
        configureTableView()
        T.getTeam(gameCode, teamName)
    }
    
    private func configureTableView() {
        table.delegate = self
        table.dataSource = self
        table.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        table.backgroundColor = .clear
        table.allowsSelection = false
        table.separatorStyle = .none
    }
    @IBAction func leaveButtonPressed(_ sender: UIButton) {
        alert(title: "니 팀 버려?", message: "Do you really want to leave your team?", sender: sender)
    }
    
    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func alert(title: String, message: String, sender: UIButton) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Stay", style: .cancel, handler: nil))
        let action = UIAlertAction(title: "Leave", style: .default, handler: { [self]action in
            T.leaveTeam(self.gameCode, self.teamName, self.currentPlayer)
            self.performSegue(withIdentifier: "returntoCorJ", sender: sender)
        })
        alert.addAction(action)
        present(alert, animated: true)
    }

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
extension TeamViewController: GetTeam {
    func getTeam(_ team: Team) {
        self.team = team
        table.reloadData()
    }
}



