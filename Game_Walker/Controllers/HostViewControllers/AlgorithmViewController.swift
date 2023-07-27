//
//  AlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/22.
//

import UIKit

class AlgorithmViewController: BaseViewController {
    
    @IBOutlet weak var startGameButton: UIButton!
    private var stationList: [Station]? = nil
    private var grid: [[Int]] = [[Int]]()
    private var totalrow : Int =  0
    private var totalcolumn : Int = 0
    
//    private var team_smallerthaneight : Bool = false
//    private var station_smallerthaneight : Bool = false
//    private var round_smallerthaneight : Bool = false
    private var num_rounds : Int = 0
    private var num_teams : Int = 0
    private var num_stations : Int = 0
    
    
    private var needHorizontalEmptyCells = false
    private var needVerticalEmptyCells = false
    private var horizontalEmptyCells = 0
    private var verticalEmptyCells = 0
    //options: "none", "teams", "stations"
    private var excessOf = "none"
    private var excessCells = 0
    

    private var collectionViewWidth = UIScreen.main.bounds.width * 0.85
    private var collectionViewCellWidth : Int = 0
    private var collectionViewCellSpacing = 4
    
    private var num_cols : Int = 8
    private var num_rows : Int = 8

    private var gamecode = UserData.readGamecode("gamecode")!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var pvpGameCount : Int = 0
    private var pveGameCount : Int = 0

    var indexPathA: IndexPath?
    var indexPathB: IndexPath?
    
    var originalcellAimage: UIImage?
    var originalcellAcolor: UIColor?
    var originalcellBimage: UIImage?
    var originalcellBcolor: UIColor?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        S.delegate_stationList = self
        S.getStationList(gamecode)
        H.delegate_getHost = self
        H.getHost(gamecode)
        collectionView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        collectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewWidth)
        collectionView.dragInteractionEnabled = true

//        print(collectionView.frame, "  HMMMM  ")
        collectionView.delegate = self
//print("CELL WIDTH: ", cellWidth, " :CELL WIDTH")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.createGrid()
            self.collectionView.dataSource = self
            self.collectionView.dragDelegate = self
            self.collectionView.dropDelegate = self
            self.collectionView.clipsToBounds = true
            self.collectionView.isUserInteractionEnabled = true
            self.collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")
            

        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

         
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        
        

//        print("cell spacing , cell width, view width : ", collectionViewCellSpacing, collectionViewCellWidth, collectionViewWidth)
        flowlayout.minimumLineSpacing = CGFloat(collectionViewCellSpacing)
        flowlayout.minimumInteritemSpacing = CGFloat(collectionViewCellSpacing)
        
        collectionView.collectionViewLayout = flowlayout
           
        let widthConstraint = NSLayoutConstraint(item: collectionView!, attribute: .width, relatedBy: .equal, toItem: nil,attribute: .notAnAttribute, multiplier: 1.0, constant: 400)
        if collectionViewCellWidth > 0  {
            createBorderLines()
        }
        

    }

    
    @IBAction func startGameButtonPressed(_ sender: UIButton) {
        alert2(title: "", message: "Everything set?")
    }
    
    func createBorderLines() {
        
        var positions: [(Int, Int)] = []

        for i in 0..<pvpGameCount {
            let one = i * 2 + 1
            let two = i * 2 + 2
            positions.append((one, two))
        }
        
        for position in positions {
            let first = position.0
            let second = position.1
        
            let borderView = VerticalBorderView(frame: CGRect(x: Int(getLinePosition(firstColumn: first, secondColumn: second) ?? 0), y: 3, width: 2, height: Int(getLineLength(smallerThanEight: needVerticalEmptyCells)!)))
            collectionView.addSubview(borderView)
        }
    }
    
    func getLinePosition(firstColumn: Int, secondColumn: Int ) -> CGFloat? {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let indexPath1 = IndexPath(item: firstColumn, section: 0)
            let indexPath2 = IndexPath(item: secondColumn, section: 0)
            
            if let attributes1 = layout.layoutAttributesForItem(at: indexPath1),
               let attributes2 = layout.layoutAttributesForItem(at: indexPath2) {
                let midpointX = (attributes1.frame.midX + attributes2.frame.midX) / 2.0
                return midpointX
            }
        }
        return nil
    }
                                                 
    func getLineLength(smallerThanEight: Bool) -> CGFloat? {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let topCellIndexPath = IndexPath(item: 0, section: 0)
            var bottomCellIndexPath = IndexPath(item: 0, section: collectionView.numberOfSections - 1)
            if smallerThanEight {
                bottomCellIndexPath  = IndexPath(item: 0, section: collectionView.numberOfSections - 1 - verticalEmptyCells)
            }
            if let topAttributes = layout.layoutAttributesForItem(at: topCellIndexPath),
               let bottomAttributes = layout.layoutAttributesForItem(at: bottomCellIndexPath) {
                let length = bottomAttributes.frame.maxY - topAttributes.frame.minY - 3
                return length
                }
            }
            return nil
        }
                                                 
                                                 
    
    
    func createGrid() {
        num_stations = stationList!.count

//        if (num_stations < num_teams) {
//            alert(title:"We need more game stations!", message:"There are teams that don't have a game.")
//        }
//        if (num_teams < num_stations) {
//            alert(title:"We need more game stations!", message:"There are teams that don't have a game.")
//        }
        
        
        if (max(num_teams, num_stations) < 8) {
            needHorizontalEmptyCells = true
            horizontalEmptyCells = 8 - max(num_teams, num_stations)
            if (num_teams < 8) {
                num_teams = 8
            }
            if (num_stations < 8) {
                num_stations = 8
            }
        }

        if (num_rounds < 8) {
            needVerticalEmptyCells = true
            verticalEmptyCells = 8 - num_rounds
        }
        if (num_stations < num_teams) {
            excessOf = "teams"
            excessCells = num_teams - num_stations
        }
        if (num_teams < num_stations) {
            excessOf = "stations"
            excessCells = num_stations - num_teams
        }
        totalcolumn = max(num_teams, num_stations)
        totalrow = max(num_rounds, 8)
        
        num_cols = totalcolumn
        num_rows = totalrow
//        print(totalrow)
        
        for r in 0...(totalrow - 1) {
            var curr_row = [Int]()
            for t in 0...(totalcolumn - 1) {
                var number = (t + (r + 1))%totalcolumn
                if (number == 0) {
                    number = totalcolumn
                }
                curr_row.append(number)
            }
            grid.append(curr_row)
            curr_row.removeAll()
        }
        

        // case when we need empty cells vertically
        if needVerticalEmptyCells {
            if verticalEmptyCells <= grid.count {
                let startIndex = grid.count - verticalEmptyCells
                
                for index in startIndex..<grid.count {
                    grid[index] = Array(repeating: 0, count: grid[index].count)
                }
            } else {
                print("Invalid value for vertical empty cells")
            }
        }

        
        // case when we need empty cells horizontally
        if needHorizontalEmptyCells {
            for rowIndex in 0..<grid.count {
                let row = grid[rowIndex]
                
                if horizontalEmptyCells <= row.count {
                    let startIndex = row.count - horizontalEmptyCells
                    for index in startIndex..<row.count {
                        grid[rowIndex][index] = 0
                    }
                } else {
                    print("Invalid value for horizontal empty cells")
                }
            }
        }
        
        // case when considering pvp cases
        
        guard pvpGameCount > 0 && pvpGameCount <= grid.count else {
            print("Invalid number of pvp games compared to number of teams")
            return
        }
        
        for rowIndex in stride(from: 1, through:grid.count - 1, by: 2) {
            for i in 0..<(pvpGameCount * 2) {
                grid[rowIndex][i] = -1
            }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)

        if indexPathA == nil {
            // First selection
            indexPathA = indexPath
            
            let selectedCellA = collectionView.cellForItem(at: indexPathA!) as? AlgorithmCollectionViewCell
            originalcellAimage = selectedCellA?.algorithmCellBox.image
            originalcellAcolor = selectedCellA?.teamnumLabel.textColor

            selectedCellA?.makeCellSelected()

            
        } else if indexPathB == nil {
            // Second selection
            indexPathB = indexPath
            
            
            let selectedCellB = collectionView.cellForItem(at: indexPathB!) as? AlgorithmCollectionViewCell
            originalcellBimage = selectedCellB?.algorithmCellBox.image
            originalcellBcolor = selectedCellB?.teamnumLabel.textColor
            selectedCellB?.makeCellSelected()

        }
        
        if let indexPathA = indexPathA, let indexPathB = indexPathB {
            let itemA = grid[indexPathA.section][indexPathA.item]
            let itemB = grid[indexPathB.section][indexPathB.item]
            

            
            grid[indexPathA.section][indexPathA.item] = itemB
            grid[indexPathB.section][indexPathB.item] = itemA
            
            collectionView.performBatchUpdates({

                
                collectionView.moveItem(at: indexPathA, to: indexPathB)
                collectionView.moveItem(at: indexPathB, to: indexPathA)
            }, completion: { _ in
                // Swap completed
                print("swap completed:", self.grid)
                let selectedCellA = collectionView.cellForItem(at: indexPathA) as? AlgorithmCollectionViewCell
                let selectedCellB = collectionView.cellForItem(at: indexPathB) as? AlgorithmCollectionViewCell
                
                selectedCellA?.algorithmCellBox.image = self.originalcellAimage
                selectedCellA?.teamnumLabel.textColor = self.originalcellAcolor
                selectedCellB?.algorithmCellBox.image = self.originalcellBimage
                selectedCellB?.teamnumLabel.textColor = self.originalcellBcolor
                
                
                self.indexPathA = nil
                self.indexPathB = nil
            })
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlgorithmCollectionViewCell.identifier, for: indexPath) as? AlgorithmCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        cell.addGestureRecognizer(doubleTapGestureRecognizer)

        let teamNumberLabel = grid[indexPath.section][indexPath.item]
        
//        print(teamnumberlabel)
        
        // configure cells differently based on what it is
        if teamNumberLabel == 0 {
            cell.makeCellInvisible()
        } else if teamNumberLabel == -1 {
            cell.makeCellEmpty()
        }else {
            cell.configureAlgorithmNormalCell(cellteamnum : teamNumberLabel)
        }

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cellNumber = grid[indexPath.section][indexPath.item]
        
        if shouldDisableInteraction(for: cellNumber) {
            return false
        }
        
        return true
    }

    func shouldDisableInteraction(for cellNumber: Int) -> Bool {
        return cellNumber == 0
    }


    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? AlgorithmCollectionViewCell else { return }
        cell.makeCellOriginal()
        let alertController = UIAlertController(title: "Enter the team number", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let numberString = alertController.textFields?.first?.text,
               let number = Int(numberString) {
                
                cell.teamnumLabel.text = "\(number)"
                if number == 0 {
                    cell.makeCellEmpty()
                }
            }
        }))
        present(alertController, animated: true, completion: nil)
        
        // deselects cell when it is double tapped.
        if let indexPaths = collectionView.indexPathsForSelectedItems, !indexPaths.isEmpty {
            let indexPath = indexPaths[0]
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

}
        





extension AlgorithmViewController: StationList {
    func listOfStations(_ stations: [Station]) {
        self.stationList = stations
        self.num_stations = stations.count
        self.collectionView?.reloadData()
        var pvpCount = 0
        for station in stations {
            if station.pvp {
                pvpCount += 1
            }
        }
        self.pvpGameCount = pvpCount
        self.pveGameCount = stations.count - pvpCount

//        print("stationsList is empty? : " , stations.count , " and ", self.stationList!.count)
    }
    
}


extension AlgorithmViewController: GetHost {
    func getHost(_ host: Host) {
//        print("algorithm protocol")
        self.num_teams = host.teams
        self.num_rounds = host.rounds

        self.collectionView?.reloadData()
        
    }
}


extension AlgorithmViewController: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (Int(collectionViewWidth - 20) - (16 * collectionViewCellSpacing)) / 8

        collectionViewCellWidth = width > 0 ? Int(width) : Int(width - 1)
//        collectionViewCellWidth = 30
        
//        collectionViewCellWidth = Int(collectionViewWidth / 11.5)
//print("THIS IS MY COLLECTION VIEW CELL WIDTH AND VIEW WIDTH: ", collectionViewCellWidth, collectionViewWidth)
        
        return CGSize(width: collectionViewCellWidth, height: collectionViewCellWidth)

    }
    


}

extension AlgorithmViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == collectionView {
//            print("------Collection view scrolling-----")
//        } else if scrollView == self.scrollView {
//            print("------Scroll view scrolling-------")
//        }
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

