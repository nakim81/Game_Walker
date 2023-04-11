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
    


    var collectionViewWidth = UIScreen.main.bounds.width * 0.6
    var collectionViewCellWidth : Int = 0
    
    var num_cols : Int = 8
    var num_rows : Int = 8

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
        scrollView.isScrollEnabled = true
        collectionView.dragInteractionEnabled = true
//        collectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewWidth)
        print(collectionView.frame, "  HMMMM  ")
//        scrollView.contentSize = collectionView.contentSize
//        cellWidth = (Int(collectionViewWidth) - 4 * 16) / 8
//        cellWidth = 17
        collectionView.delegate = self
//print("CELL WIDTH: ", cellWidth, " :CELL WIDTH")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.createGrid()
            self.collectionView.dataSource = self
            self.collectionView.dragDelegate = self
            self.collectionView.dropDelegate = self

            self.collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")

        }

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        collectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewWidth)
        addviewsConstraints()

//        scrollView.contentSize = collectionView.contentSize

    }

    
    @IBAction func startGameButtonPressed(_ sender: UIButton) {
        alert2(title: "", message: "Everything set?")
    }
    func createGrid() {
        num_stations = /*stationList!.count**/ 8

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
        
        num_cols = totalcolumn
        num_rows = totalrow
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
//        if (num_stations - num_teams) == 0 {
//            deficit = "none"
//            cell.configureAlgorithmNormalCell(cellteamnum : teamnumberlabel)
//        }
//        else if min(num_stations, num_teams) == num_stations {
//            deficit = "stations"
//            deficit_amount = min(num_stations, num_teams)
//            cell.configureAlgorithmSpecialCell2(cellteamnum : teamnumberlabel)
//        } else {
//            deficit = "teams"
//            deficit_amount = min(num_stations, num_teams)
//            cell.configureAlgorithmSpecialCell1()
//        }
        cell.configureAlgorithmNormalCell(cellteamnum : teamnumberlabel)
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
        let numberOfCellsPerRow = 8
        //this calculates how big the cellshould be
        collectionViewCellWidth = Int(collectionViewWidth / CGFloat(numberOfCellsPerRow))

        // this calculates the contentsize
        let width = (collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right - 0 * (8 - 1)) / 8
        let height = (collectionView.frame.height - collectionView.contentInset.top - collectionView.contentInset.bottom - 0 * (8 - 1)) / 8
        collectionViewCellWidth = Int(width)
        print("CONTENT INSETS: ", collectionView.contentInset.top,collectionView.contentInset.bottom, collectionView.contentInset.left, collectionView.contentInset.right)
        return CGSize(width: width, height: height)
//        print("ISIT COMING THROUGH TH ECELL SIZE")
//        return CGSize(width: 10, height: 10)

//

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        print("ITS MINIMUM INTERIMADFADAFADFADFADFA")
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        // Although the collection shows 8 x 8 in default, the content should be able to be larger.
//        let col_nums = max(num_stations, num_teams)
//        // 4 is the space between cells
//        let contentWidth = (4 * (col_nums + 1)) + (col_nums * cellWidth)
//
//        let row_nums = grid.count
//        print("col_nums = ", col_nums, "row_nums = ", row_nums)
//        let contentHeight = (4 * (row_nums + 1)) + (row_nums * cellWidth)
//
//        collectionView.contentSize = CGSize(width: contentWidth, height: contentHeight)
//
//    }
    func addviewsConstraints() {
        print("HEYEYEYEYEY IM INNN")
        let flowLayout = AlgorithmCustomFlowLayout()
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let contentSize = CGSize(width: collectionViewCellWidth * num_cols, height: collectionViewCellWidth * num_rows)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = contentSize
        scrollView.isDirectionalLockEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalToConstant: collectionViewWidth),
            scrollView.heightAnchor.constraint(equalToConstant: collectionViewWidth),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: contentSize.width),
            collectionView.heightAnchor.constraint(equalToConstant: contentSize.height),
            collectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])

        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.contentSize = contentSize
//        let flowLayout = AlgorithmCustomFlowLayout()
//        collectionView.collectionViewLayout = flowLayout
//
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        let contentSize = CGSize(width: collectionViewWidth * 2, height: collectionViewWidth * 2)
//
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
     ////   scrollView.backgroundColor = .yellow
//        scrollView.contentSize = contentSize
//        scrollView.isDirectionalLockEnabled = true
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
      ////  collectionView.backgroundColor = .green
//
////        scrollView.addSubview(collectionView)
////        view.addSubview(scrollView)
//
//        NSLayoutConstraint.activate([
//            scrollView.widthAnchor.constraint(equalToConstant: collectionViewWidth),
//            scrollView.heightAnchor.constraint(equalToConstant: collectionViewWidth),
//            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//
//            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            collectionView.widthAnchor.constraint(equalToConstant: contentSize.width),
//            collectionView.heightAnchor.constraint(equalToConstant: contentSize.height),
//            collectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            collectionView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
//        ])
//
//
//        collectionView.collectionViewLayout.invalidateLayout()
//        collectionView.contentSize = contentSize
        
        print(collectionView.frame.size, "<- this is my collection view frame size! ", collectionView.contentSize, "<- This is my content Size!", scrollView.contentSize, "<- this is my scrollview content size!")

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
