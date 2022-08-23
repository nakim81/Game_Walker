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
    let data: [String] = ["Hi", "Hello", "Ni hao"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    
    }
    
    private func configureTableView() {
        table.delegate = self
        table.dataSource = self
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = data[indexPath.row]
        let cell = table.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
        cell.nameLabel.text = name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return team!.players.count
    }
}

// MARK: - TeamProtocol
extension TeamViewController: GetTeam {
    func getTeam(_ team: Team) {
        self.team = team
    }
}



