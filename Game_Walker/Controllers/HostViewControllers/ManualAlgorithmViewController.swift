//
//  ManualAlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 4/2/23.
//

import UIKit

class ManualAlgorithmViewController: BaseViewController {
    
    private var gamecode = UserData.readGamecode("gamecode")!
    
    var stationList: [Station]? = nil
    var grid: [[Int]] = [[Int]]()
    var totalrow : Int =  0
    var totalcolumn : Int = 0
    
    var team_smallerthaneight : Bool = false
    var station_smallerthaneight : Bool = false
    var round_smallerthaneight : Bool = false
    var num_rounds : Int = 0
    var num_teams : Int = 0
    var num_stations : Int = 0
    
    
    var collectionViewWidth = UIScreen.main.bounds.width * 0.7
    var cellWidth : Int = 0
    
    var collectionView: UICollectionView!
    
    let layout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        S.delegate_stationList = self
        S.getStationList(gamecode)
        H.delegate_getHost = self
        H.getHost(gamecode)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.isScrollEnabled = false
        collectionView.dragInteractionEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.createGrid()
            self.layout.minimumInteritemSpacing = 3
            self.layout.minimumLineSpacing = 3
            self.layout.scrollDirection = .vertical
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")
            self.collectionView.backgroundColor = UIColor.white
            self.collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")
            self.view.addSubview(self.collectionView)
            
            // Set constraints for the collection view to fill the view
            NSLayoutConstraint.activate([
                self.collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.65),
                self.collectionView.heightAnchor.constraint(equalTo: self.collectionView.widthAnchor),
                self.collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set the content size of the scroll view to be larger than the frame size of the collection view
        let contentSize = CGSize(width: collectionView.frame.width * 2, height: collectionView.frame.height * 2)
        let scrollView = UIScrollView(frame: .zero)
        scrollView.contentSize = contentSize
        scrollView.addSubview(collectionView)
        view.addSubview(scrollView)
        
        // Set constraints for the scroll view to fill the view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func createGrid() {
        num_stations = stationList!.count

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
        print("This is my grid: ", grid)
    }


}
    extension ManualAlgorithmViewController: UICollectionViewDelegate, UICollectionViewDataSource {
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 8
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 8
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlgorithmCollectionViewCell", for: indexPath)
            cell.backgroundColor = UIColor.lightGray
            return cell
        }
        
        
    }
    
    extension ManualAlgorithmViewController: UICollectionViewDelegateFlowLayout {
        func cellSize() -> CGFloat {
            return (collectionView.frame.width - layout.minimumInteritemSpacing * 7) / 8
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: cellSize(), height: cellSize())
        }
    }
    

    

 

extension ManualAlgorithmViewController: StationList {
    func listOfStations(_ stations: [Station]) {
        self.stationList = stations
        self.num_stations = stations.count
        self.collectionView?.reloadData()
        print("stationsList is empty? : " , stations.count , " and ", self.stationList!.count)

    }
    
}


extension ManualAlgorithmViewController: GetHost {
    func getHost(_ host: Host) {
        print("algorithm protocol")
        self.num_teams = host.teams
        self.num_rounds = host.rounds
        self.collectionView?.reloadData()
        
    }
}
