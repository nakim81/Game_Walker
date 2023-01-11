//
//  AlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/22.
//

import UIKit

class AlgorithmViewController: BaseViewController {
    
    var curr_gamecode = UserData.gamecode
    var stationList: [Station] = []
//    var teamList: [Team] = []
    var host: Host?
//    var teamnums :[Int] = []
    var grid: [[Int]] = []
    var rowcount : Int =  0

    @IBOutlet weak var collectionView: UICollectionView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        S.delegate_stationList = self
        S.getStationList(curr_gamecode)
//        T.delegate_teamList = self
//        T.getTeamList(curr_gamecode)
        H.delegate_getHost = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }


}

extension AlgorithmViewController: UICollectionViewDelegate{
    
}

extension AlgorithmViewController: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return grid.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ((host!.rounds < 8) && (host!.teams < 8)) {
            return 8
        } else {
            return grid[section].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlgorithmCollectionViewCell", for: indexPath) as? AlgorithmCollectionViewCell, let columns = grid.first?.count {
            let item = indexPath.item
            let row : Int = rowcount
            let column : Int = Int(CGFloat(item).truncatingRemainder(dividingBy: CGFloat(columns)))
//        else { return UICollectionViewCell() }
//        let num_team = teamList[indexPath.item].number
//        let num_team = host!.teams
//        var num_cols = stationList.count
//        var num_rows = host!.rounds
        if (column == 8) {
            rowcount += 1
        }
            cell.configureAlgorithmCell(cellteamnum:grid[row][column])
        return cell
        }
        return UICollectionViewCell();
    }
}

extension AlgorithmViewController: StationList {
    func listOfStations(_ stations: [Station]) {
        self.stationList = stations
        self.collectionView?.reloadData()
    }
    
}

//extension AlgorithmViewController: TeamList {
//
//    func listOfTeams(_ teams: [Team]) {
//        self.teamList = teams
//        self.collectionView?.reloadData()
//    }
//}

extension AlgorithmViewController: GetHost {
    func getHost(_ host: Host) {
        self.host = host
        self.collectionView?.reloadData()
    }
}
