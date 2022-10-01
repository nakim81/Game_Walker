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
    //let data: [String] = ["Hi", "Hello", "Ni hao"]
    //private lazy var gamecode = userData.string(forKey: "gamecode")!
    //private lazy var myTeam = userData.object(forKey: "team") as? Team
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegate_getTeam = self
        configureTableView()
        T.getTeam(UserData.gamecode!, UserData.team!.name)
    
    }
    
    private func configureTableView() {
        table.delegate = self
        table.dataSource = self
        table.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
        cell.configureTableViewCell(name: team!.players[indexPath.row].name)
        print(team!.players[indexPath.row])
        return cell
        
    }
    
    private var cellColors = ["F28044","F0A761","FEC362","F0BB4C","E3CB92","FEA375"]
    private func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor(named: cellColors[indexPath.row % cellColors.count])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let team = team else {
            return 0
        }
        print(team.players.count)
        return team.players.count
    }
}

// MARK: - TeamProtocol
extension TeamViewController: GetTeam {
    func getTeam(_ team: Team) {
        self.team = team
        self.table.reloadData()
    }
}



