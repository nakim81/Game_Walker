//
//  AlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/22.
//

import UIKit

class AlgorithmViewController: BaseViewController {
    
    @IBOutlet weak var startGameButton: UIButton!
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
    
    private var gamecode = UserData.readGamecode("gamecode")!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        S.delegate_stationList = self
        S.getStationList(gamecode)
        H.delegate_getHost = self
        H.getHost(gamecode)
        collectionView.isScrollEnabled = false
        collectionView.dragInteractionEnabled = true
//        collectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewWidth)
        print(collectionView.frame, "  HMMMM  ")
//        scrollView.contentSize = collectionView.contentSize
//        cellWidth = (Int(collectionViewWidth) - 4 * 16) / 8
        cellWidth = 17
print("CELL WIDTH: ", cellWidth, " :CELL WIDTH")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.createGrid()
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.dragDelegate = self
            self.collectionView.dropDelegate = self

            self.collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")
            
        }

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewWidth)
//        scrollView.contentSize = collectionView.contentSize
        print(collectionView.frame.size, "<- this is my collection view frame size! ", collectionView.contentSize, "<- This is my content Size!", scrollView.contentSize, "<- this is my scrollview content size!")
    }

    
    @IBAction func startGameButtonPressed(_ sender: UIButton) {
        alert2(title: "", message: "Everything set?")
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlgorithmCollectionViewCell.identifier, for: indexPath) as? AlgorithmCollectionViewCell else {
            return UICollectionViewCell()
        }

        let teamnumberlabel = grid[indexPath.section][indexPath.item]
        
        print(teamnumberlabel)

        // start new code
        var deficit_amount = 0
        var deficit : String
        if (num_stations - num_teams) == 0 {
            deficit = "none"
            cell.configureAlgorithmNormalCell(cellteamnum : teamnumberlabel)
        }
        else if min(num_stations, num_teams) == num_stations {
            deficit = "stations"
            deficit_amount = min(num_stations, num_teams)
            cell.configureAlgorithmSpecialCell2(cellteamnum : teamnumberlabel)
        } else {
            deficit = "teams"
            deficit_amount = min(num_stations, num_teams)
            cell.configureAlgorithmSpecialCell1()
        }
        return cell
    }
}
        



extension AlgorithmViewController: StationList {
    func listOfStations(_ stations: [Station]) {
        self.stationList = stations
        self.num_stations = stations.count
        self.collectionView?.reloadData()
        print("stationsList is empty? : " , stations.count , " and ", self.stationList!.count)
    }
    
}


extension AlgorithmViewController: GetHost {
    func getHost(_ host: Host) {
        print("algorithm protocol")
        self.num_teams = host.teams
        self.num_rounds = host.rounds

        self.collectionView?.reloadData()
        
    }
}


extension AlgorithmViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // calculates cell size.
        // however this should be the same as it assumes the collection view to display 8 cells no matter what.
        print(cellWidth ," ECECELL WIDTHT")
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Although the collection shows 8 x 8 in default, the content should be able to be larger.
        let col_nums = max(num_stations, num_teams)
        // 4 is the space between cells
        let contentWidth = (4 * (col_nums + 1)) + (col_nums * cellWidth)
        
        let row_nums = grid.count
        print("col_nums = ", col_nums, "row_nums = ", row_nums)
        let contentHeight = (4 * (row_nums + 1)) + (row_nums * cellWidth)
        
        collectionView.contentSize = CGSize(width: contentWidth, height: contentHeight)

    }
    
    func addCollectionViewConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func addScrollViewConstraints() {
        let scrollView = UIScrollView(frame: .zero)
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentSize = CGSize(width: collectionView.frame.width * 1.5, height: collectionView.frame.height * 1.5)
        scrollView.contentSize = contentSize
        
        scrollView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            scrollView.heightAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}


extension AlgorithmViewController: UICollectionViewDropDelegate, UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = indexPath
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        coordinator.session.loadObjects(ofClass: NSArray.self as! any NSItemProviderReading.Type) { items in
            guard let sourceIndexPaths = items as? [IndexPath] else { return }
            
            collectionView.performBatchUpdates({
                var deleteIndexPaths = [IndexPath]()
                var insertIndexPaths = [IndexPath]()
                
                for sourceIndexPath in sourceIndexPaths {
                    if sourceIndexPath.section == destinationIndexPath.section {
                        if sourceIndexPath.item < destinationIndexPath.item {
                            deleteIndexPaths.append(sourceIndexPath)
                            insertIndexPaths.append(destinationIndexPath)
                        } else if sourceIndexPath.item > destinationIndexPath.item {
                            deleteIndexPaths.append(sourceIndexPath)
                            insertIndexPaths.append(destinationIndexPath)
                        }
                    } else {
                        // Moving to different section
                        deleteIndexPaths.append(sourceIndexPath)
                        insertIndexPaths.append(destinationIndexPath)
                    }
                }
                
                collectionView.deleteItems(at: deleteIndexPaths)
                collectionView.insertItems(at: insertIndexPaths)
                
            }, completion: nil)
            
            coordinator.drop(coordinator.items.first!.dragItem, toItemAt: destinationIndexPath)
        }
    }
}
