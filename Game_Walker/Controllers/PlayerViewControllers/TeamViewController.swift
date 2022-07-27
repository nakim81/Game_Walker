//
//  PlayerFrame4_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class TeamViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
<<<<<<< Updated upstream
    @IBOutlet weak var tableView: UITableView!
=======
    @IBOutlet weak var table: UITableView!
>>>>>>> Stashed changes
    var team: Team?
    var teams: [Int?] = []
    let data: [String] = ["Hi", "Hello", "Ni hao"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    private func configureTableView() {
<<<<<<< Updated upstream
        tableView.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false
        tableView.clipsToBounds = false
=======
        tableView.register(TeamTableViewCell.self, forCellWithReuseIdentifier: TeamTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.allowsMultipleSelection = false
        table.clipsToBounds = false
>>>>>>> Stashed changes
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = data[indexPath.row]
<<<<<<< Updated upstream
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
=======
        let cell = table.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
>>>>>>> Stashed changes
        cell.nameLabel.text = name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
}


