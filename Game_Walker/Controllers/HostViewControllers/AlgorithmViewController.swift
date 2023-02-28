//
//  AlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/22.
//

import UIKit

class AlgorithmViewController: BaseViewController {
    
    @IBOutlet weak var startGameButton: UIButton!
    var stationList: [Station] = []
//    var teamList: [Team] = []
    var host: Host!
//    var teamnums :[Int] = []
    var grid: [[Int]] = [[Int]]()
    var rowcount : Int =  0
    var smallerthaneight : Bool = false
    var num_rounds : Int = 0
    var num_teams : Int = 0
    var columncount : Int = 0

    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        S.delegate_stationList = self
        S.getStationList(UserData.readGamecode("gamecodestring")!)

//        T.delegate_teamList = self
//        T.getTeamList(curr_gamecode)
        H.delegate_getHost = self
        H.getHost(UserData.readGamecode("gamecodestring")!)
//        H.getHost("705154")
    
        collectionView.delegate = self
        collectionView.dataSource = self
        createGrid()
    }
    
    @IBAction func startGameButtonPressed(_ sender: UIButton) {
        alert2(title: "", message: "Everything set?")
    }
    func createGrid() {
        var num_stations = stationList.count
        var t_lessthan_eight = false
        var s_lessthan_eight = false
        var t_zeros = 0
        var s_zeros = 0
        var r_lessthan_eight = false
        var r_zeros = 0
        if (num_stations < num_teams) {
            alert(title:"We need more game stations!", message:"There are teams that don't have a game.")
        }
        if (num_teams < num_stations) {
            alert(title:"We need more game stations!", message:"There are teams that don't have a game.")
        }

        if (num_teams < 8) {
            t_zeros = 8 - num_teams
            t_lessthan_eight = true
            num_teams = 8
        }
        if (num_stations < 8) {
            s_zeros = 8 - num_stations
            s_lessthan_eight = true
            num_stations = 8
        }
        columncount = max(num_teams, num_stations)
//        if (r_zero)
//        var curr_row = [Int]()
//        curr_row.append("C1")
//        for r in 0...(num_rounds - 1) {
//            var curr_row = [Int]()
//            for t in 0...(columncount - 1) {
//                curr_row.append((t + (r + 1))%columncount)
//            }
//            grid.append(curr_row)
//            curr_row.removeAll()
//        }
//        let team_counter = 0
//        let station_counter = 0
//        for s in 0...(num_stations - 1){
//            for t in 1...num_teams{
//                if (s_lessthan_eight && (s >= num_stations - s_zeros)) {
//                    grid[s].append(0)
//                } else {
//                    if (t_lessthan_eight && (t > num_teams - t_zeros)) {
//                        grid[s].append(0)
//                    }
//                    grid[s].append(t)
//                }
//                print(grid)
//            }
//        }
    }


}

extension AlgorithmViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return grid.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ((stationList.count < 8) && (host!.teams < 8)) {
            smallerthaneight = true
            return 8
        } else {
            return grid[section].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlgorithmCollectionViewCell.identifier, for: indexPath) as? AlgorithmCollectionViewCell, let columns = grid.first?.count {
            if smallerthaneight {
                let columns = 8
            }
            let item = indexPath.item
            let row : Int = rowcount
            let column : Int = Int(CGFloat(item).truncatingRemainder(dividingBy: CGFloat(columns)))
//        else { return UICollectionViewCell() }
//        let num_team = teamList[indexPath.item].number
//        let num_team = host!.teams
//        var num_cols = stationList.count
//        var num_rows = host!.rounds
        if (column == columns) {
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
        print("algorithm protocol")
        self.host = host
        self.num_teams = host.teams
        self.num_rounds = host.rounds
        self.collectionView?.reloadData()
    
        
    }
}
