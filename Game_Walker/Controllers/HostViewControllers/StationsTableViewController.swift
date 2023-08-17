//
//  StationsTableViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 8/18/22.
//

import UIKit

class StationsTableViewController: BaseViewController {
    
    var currentStations: [Station] = []

    var curr_gamecode = UserData.readGamecode("gamecode")
    
    @IBOutlet weak var stationTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stationTable.register(UINib(nibName: "HostStationsTableViewCell", bundle: nil), forCellReuseIdentifier: "HostStationsTableViewCell")
        stationTable.delegate = self
        stationTable.dataSource = self
        stationTable.separatorStyle = UITableViewCell.SeparatorStyle.none
        S.delegate_stationList = self
        S.getStationList(curr_gamecode!)
    }
    
    func reloadStationTable() {
        S.getStationList(curr_gamecode!)
        self.stationTable.reloadData()
    }
    

}

extension StationsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            self.deleteStation(at: indexPath)
            
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }

    
    func deleteStation(at indexPath: IndexPath) {
        print("It will activate the delete function!")
    }
}

extension StationsTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentStations.count
    }
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let cell = stationTable.cellForRow(at: indexPath) {
            cell.isUserInteractionEnabled = false
        }
    }
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath, let cell = stationTable.cellForRow(at: indexPath) {
            cell.isUserInteractionEnabled = true
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stationTable.dequeueReusableCell(withIdentifier: "HostStationsTableViewCell", for: indexPath) as! HostStationsTableViewCell
        let curr_cellname = currentStations[indexPath.row].name
        cell.configureStationCell(stationName: curr_cellname)
        cell.backgroundView = UIImageView(image: UIImage(named: "cell-with-transparent"))
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddStationViewController") as? AddStationViewController {
            vc.stationExists = true
            vc.station = currentStations[indexPath.row]
            
            
            self.navigationController?.present(vc, animated: true)
            
        }
    }
    
    
}

extension StationsTableViewController: StationList {
    func listOfStations(_ stations: [Station]) {
        currentStations = stations
        reloadStationTable()
    }
    
}
