//
//  StationsTableViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 8/18/22.
//

import UIKit

class StationsTableViewController: BaseViewController {
    
    private var currentStations: [Station] = []

    private var gamecode = UserData.readGamecode("gamecode")
    
    private let refreshController : UIRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var stationTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        S.delegate_stationList = self
//        S.getStationList(gamecode!)
//        S.getStationList(gamecode!)
        getStationList()
        stationTable.register(UINib(nibName: "HostStationsTableViewCell", bundle: nil), forCellReuseIdentifier: "HostStationsTableViewCell")
        stationTable.delegate = self
        stationTable.dataSource = self
        stationTable.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        stationTable.refreshControl = refreshController
        settingRefreshControl()
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddStationSegue",
            let addStationVC = segue.destination as? AddStationViewController,
            let selectedStation = sender as? Station {
            addStationVC.stationExists = true
            addStationVC.station = selectedStation
            addStationVC.delegate = self
            
        }
    }
    
    private func getStationList() {
        Task { @MainActor in
            do {
                currentStations = try await S.getStationList2(gamecode!)
            } catch(let e) {
                print(e)
                alert(title: "Connection Error", message: e.localizedDescription)
                return
            }
        }
        DispatchQueue.main.async {
            self.stationTable.reloadData()
            self.refreshController.endRefreshing()
        }
    }
    
    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.92, green: 0.75, blue: 0.99, alpha: 1.00)
        refreshController.attributedTitle = NSAttributedString(string: "", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.92, green: 0.75, blue: 0.99, alpha: 1.00), NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
    
    @objc func refreshFunction() {
        reloadStationTable()

    }
    
   func reloadStationTable() {
       S.getStationList(self.gamecode!)
        self.stationTable.reloadData()
    }
    
    

}

extension StationsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            Task {
                await self.deleteStation(at: indexPath)
            
                // Calls the completion handler after it finishes deleting station.
                completionHandler(true)
            }
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func deleteStation(at indexPath: IndexPath) async {

        print("stationList before Removal: ", currentStations)
//        print("Removed station at : " , indexPath)

        
        let stationIndex = indexPath.item
        let stationToRemove = currentStations[stationIndex]
        
        // Change referee to unassign

        let refereeToRemove = stationToRemove.referee
        Task{
            do{
                try await R.assignStation(gamecode!, refereeToRemove!.uuid, "", false)
            } catch ServerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
        }
        S.removeStation(gamecode!, stationToRemove)
        
        // Remove the station from data source
        currentStations.remove(at: stationIndex)
        
        // Reload the table view on the main thread
        DispatchQueue.main.async {
            self.stationTable.reloadData()
        }
        print("CURRENT stations List: ", currentStations)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }

        return 3
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
//        cell.backgroundView = UIImageView(image: UIImage(named: "cell-with-transparent"))
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AddStationSegue", sender: currentStations[indexPath.row])
    }
    
    
}
//
//extension StationsTableViewController: StationList {
//    func listOfStations(_ stations: [Station]) {
//        currentStations = stations
//
//        DispatchQueue.main.async {
//            self.stationTable.reloadData()
//            self.refreshController.endRefreshing()
//        }
//    }
//}

extension StationsTableViewController: AddStationDelegate {
    func didUpdateStationData() {
        S.getStationList(self.gamecode!)
            DispatchQueue.main.async {
                print("SUCCESSFULLY CAME IN TO RELOAD STATION TABLE")
                self.stationTable.reloadData()
            }
        
    }
}

