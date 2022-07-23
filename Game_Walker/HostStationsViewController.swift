//
//  HostStationsViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/14/22.
//

import UIKit

class HostStationsViewController: BaseViewController {
    @IBOutlet weak var stationsTable: UITableView!
    
    var stationNameData = ["first station"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stationsTable.register(UINib(nibName:"StationTableViewCell",bundle:nil), forCellReuseIdentifier:"StationTableViewCell")
        stationsTable.delegate = self
        stationsTable.dataSource = self
    

    }

    
    func addNewCell(with name: String) {
        stationNameData.append(name)
        //stationsTable.reloadData()
    }
}
extension HostStationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationNameData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = stationsTable.dequeueReusableCell(withIdentifier: "StationTableViewCell", for: indexPath) as? StationTableViewCell else {return UITableViewCell()}
        let cellData = stationNameData[indexPath.row]
        cell.configure(stationName: cellData)

        return cell
    }

}
