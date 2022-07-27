//
//  HostStationsViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/14/22.
//

import UIKit

class HostStationsViewController: BaseViewController {
    @IBOutlet weak var stationsTable: UITableView!
    
    var stationArray = [Station]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stationsTable.register(UINib(nibName:"StationTableViewCell",bundle:nil), forCellReuseIdentifier:"StationTableViewCell")
        stationsTable.delegate = self
        stationsTable.dataSource = self
    
        // Do any additional setup after loading the view.
    }

    
//    func addNewCell(with name: String) {
//
//        setupRequest(gamecode: K.gamecode, station: Station?, gameTime: Int?, movingTime: Int?, rounds : Int?, request: setupRequestType)
//        stationNameData.append(name)
//
//    }
}
extension HostStationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = stationsTable.dequeueReusableCell(withIdentifier: "StationTableViewCell", for: indexPath) as? StationTableViewCell else {return UITableViewCell()}
        let cellData = stationArray[indexPath.row].name
        cell.configure(stationName: cellData)
        
        return cell
    }
    
}
