//
//  HostStationsViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/14/22.
//

import UIKit

class HostStationsViewController: UIViewController {
    @IBOutlet weak var stationsTable: UITableView!
    
    var stationNameData = ["first station"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stationsTable.register(UINib(nibName:"StationTableViewCell",bundle:nil), forCellReuseIdentifier:"StationTableViewCell")
        stationsTable.delegate = self
        stationsTable.dataSource = self
    
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func addNewCell(with name: String) {
        stationNameData.append(name)
        stationsTable.reloadData()
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
