//
//  PlayerFrame4_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class TeamViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    var team: Team?
    var teams: [Int?] = []
    let cellSpacingHeight: CGFloat = 3
    //let data: [String] = ["Hi", "Hello", "Ni hao"]
    //private lazy var gamecode = userData.string(forKey: "gamecode")!
    //private lazy var myTeam = userData.object(forKey: "team") as? Team
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegate_getTeam = self
        configureTableView()
        T.getTeam(UserData.gamecode!, UserData.team!.name)
        table.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.reloadData()
    }
    
    private func configureTableView() {
        table.delegate = self
        table.dataSource = self
        table.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        table.backgroundColor = .white
        table.allowsSelection = false
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
        cell.configureTableViewCell(name: team!.players[indexPath.section].name)
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
        self.table.reloadData()
    }
}



