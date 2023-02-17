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
//    var host: Host!
//    var teamnums :[Int] = []
    var grid: [[Int]] = [[Int]]()
    var totalrow : Int =  0
    var totalcolumn : Int = 0
    
    var team_smallerthaneight : Bool = false
    var station_smallerthaneight : Bool = false
    var round_smallerthaneight : Bool = false
    var num_rounds : Int = 0
    var num_teams : Int = 0
    var num_stations : Int = 0
    
    private var gamecode = UserData.readGamecode("gamecodestring")!
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        S.delegate_stationList = self
        S.getStationList(gamecode)

//        T.delegate_teamList = self
//        T.getTeamList(curr_gamecode)
        H.delegate_getHost = self
        H.getHost(gamecode)
//        H.getHost("705154")
    
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")
        createGrid()
    }
    
    @IBAction func startGameButtonPressed(_ sender: UIButton) {
        alert2(title: "", message: "Everything set?")
    }
    func createGrid() {
        var num_stations = stationList.count

        if (num_stations < num_teams) {
            alert(title:"We need more game stations!", message:"There are teams that don't have a game.")
        }
        if (num_teams < num_stations) {
            alert(title:"We need more game stations!", message:"There are teams that don't have a game.")
        }

        if (num_teams < 8) {
            team_smallerthaneight = true
            num_teams = 8
        }
        if (num_stations < 8) {
            station_smallerthaneight = true
            num_stations = 8
        }
        totalcolumn = max(num_teams, num_stations)
        totalrow = max(num_stations, 8)

        print(totalrow)
        for r in 0...(totalrow - 1) {
            var curr_row = [Int]()
            for t in 0...(totalcolumn - 1) {
                var number = (t + (r + 1))%totalcolumn
                if (number == 0) {
                    number = totalcolumn
                }
                curr_row.append(number)
                print("r = " , r ,
                "t = " , t ,
                "totalrow = " ,totalrow ,
                      "totalcolumn = ",totalcolumn)
            }
            grid.append(curr_row)
            curr_row.removeAll()
        }
        print(grid)
    }


}

extension AlgorithmViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return grid.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ((num_stations < 8) && (num_teams < 8)) {
            return 8
        } else {
            return grid[section].count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlgorithmCollectionViewCell.identifier, for: indexPath) as? AlgorithmCollectionViewCell, let columns = grid.first?.count {
            if (station_smallerthaneight && team_smallerthaneight) {
                let columns = 8
            }
            let item = indexPath.item
            let row : Int = totalrow
            let column : Int = Int(CGFloat(item).truncatingRemainder(dividingBy: CGFloat(columns)))
//        else { return UICollectionViewCell() }
//        let num_team = teamList[indexPath.item].number
//        let num_team = host!.teams
//        var num_cols = stationList.count
//        var num_rows = host!.rounds
        if (column == columns) {
            totalrow += 1
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
        self.num_stations = stations.count
        self.collectionView?.reloadData()
    }
    
}


extension AlgorithmViewController: GetHost {
    func getHost(_ host: Host) {
        print("algorithm protocol")
        self.num_teams = host.teams
        self.num_rounds = host.rounds
        self.collectionView?.reloadData()
        print("number of teams : ",self.num_teams)
        print("number of rounds : ", self.num_rounds)
        
    }
}
