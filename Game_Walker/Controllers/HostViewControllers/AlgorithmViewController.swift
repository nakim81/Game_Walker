//
//  AlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/22.
//

import UIKit

class AlgorithmViewController: BaseViewController {
    
    var curr_gamecode = String(data: UserDefaults.standard.data(forKey: "gamecodestring")!, encoding: .utf8)!
    var stationList: [Station] = []
    var teamList: [Team] = []
    var host: Host?

    @IBOutlet weak var collectionView: UICollectionView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        S.delegate_stationList = self
        S.getStationList(curr_gamecode)
        T.delegate_teamList = self
        T.getTeamList(curr_gamecode)
        H.delegate_getHost = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    


}

extension AlgorithmViewController: UICollectionViewDelegate{
    
}

extension AlgorithmViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var num_cells = stationList.count * host!.rounds
        if (num_cells < 64) {
            num_cells = 64
            return num_cells
        } else {
            return stationList.count * host!.rounds
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlgorithmCollectionViewCell", for: indexPath) as? AlgorithmCollectionViewCell else { return UICollectionViewCell() }

        let num_team = teamList[indexPath.item].number
        cell.configureAlgorithmCell(imageName:)
        return cell
    }
    
    
}

extension AlgorithmViewController: StationList {
    func listOfStations(_ stations: [Station]) {
        self.stationList = stations
        self.collectionView?.reloadData()
    }
    
}

extension AlgorithmViewController: TeamList {
    
    func listOfTeams(_ teams: [Team]) {
        self.teamList = teams
        self.collectionView?.reloadData()
    }
}

extension AlgorithmViewController: GetHost {
    func getHost(_ host: Host) {
        self.host = host
        self.collectionView?.reloadData()
    }
}
