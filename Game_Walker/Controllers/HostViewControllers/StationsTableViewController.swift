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
    
    
    @IBOutlet weak var stationsLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var stationTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLetterSpacing(to: stationsLabel, spacing: 3)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name("stationUpdate"), object: nil)
        stationTable.delegate = self
        stationTable.dataSource = self
        stationTable.register(UINib(nibName: "HostStationsTableViewCell", bundle: nil), forCellReuseIdentifier: "HostStationsTableViewCell")
        stationTable.separatorStyle = UITableViewCell.SeparatorStyle.none
        getStationList()
        adjustAddButtonWidth()
        
        stationTable.refreshControl = refreshController
        settingRefreshControl()

        configureGamecodeLabel()
    }
    
    @objc func refresh() {
        Task {
            try await Task.sleep(nanoseconds: 250_000_000)
            guard let gamecode = self.gamecode else { return }
            self.currentStations = try await S.getStationList(gamecode)
            stationTable.reloadData()
        }
    }


    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddStationSegue" {
            if let addStationVC = segue.destination as? AddStationViewController {
                if let selectedStation = sender as? Station {
                    addStationVC.stationExists = true
                    addStationVC.station = selectedStation
                }

                addStationVC.delegate = self
            }
        }
    }
    

    @objc func stationDataUpdated(_ notification: Notification) {
        getStationList()
    }
    deinit {
        // removing the observer when the viewcontroller is deallocated
        NotificationCenter.default.removeObserver(self, name: .stationDataUpdated, object: nil)
    }
    

    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "AddStationSegue", sender: self)
    }
    
    private func adjustAddButtonWidth() {
        if let firstCell = stationTable.visibleCells.first {
            addButton.translatesAutoresizingMaskIntoConstraints = false

            // Add constraints to make the button have the same width as the first cell
            NSLayoutConstraint.activate([
                addButton.leadingAnchor.constraint(equalTo: firstCell.leadingAnchor),
                addButton.trailingAnchor.constraint(equalTo: firstCell.trailingAnchor)
            ])
        }
    }
    private func getStationList(){
        Task { @MainActor in
            do {
                currentStations = try await S.getStationList(gamecode!)
                DispatchQueue.main.async {
                    print("data reloaded for stations: ", self.currentStations)
                    self.stationTable.reloadData()
                    self.refreshController.endRefreshing()
                }
            } catch(let e) {
                print(e)
                return
            }
        }
    }
    
    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.92, green: 0.75, blue: 0.99, alpha: 1.00)
        refreshController.attributedTitle = NSAttributedString(string: "", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.92, green: 0.75, blue: 0.99, alpha: 1.00), NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
    
    
    @objc func refreshFunction() {
        Task { @MainActor in
            do {
                self.currentStations = try await S.getStationList(gamecode!)
                refreshController.endRefreshing()
                stationTable.reloadData()
            } catch (let e){
                print(e)
                return
            }
        }
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

//        print("stationList before Removal: ", currentStations)

        let stationIndex = indexPath.item
        let stationToRemove = currentStations[stationIndex]
        
        // Change referee to unassign

        let refereeToRemove = stationToRemove.referee
        Task{
            do{
                try await R.assignStation(gamecode!, refereeToRemove!.uuid, "", false)
            } catch GameWalkerError.serverError(let text){
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

extension StationsTableViewController: AddStationDelegate {
    
    func didUpdateStationData(completion: @escaping () -> Void) {
        Task { @MainActor in
            do {
                self.currentStations = try await S.getStationList(gamecode!)
                DispatchQueue.main.async {
                    print("SUCCESSFULLY CAME IN TO RELOAD STATION TABLE")
                    self.stationTable.reloadData()
                    self.refreshController.endRefreshing()
                    self.dismiss(animated: true)
                    completion() // Call the completion handler after data update
                }
            } catch (let e){
                print(e)
                return
            }
        }
    }
}

