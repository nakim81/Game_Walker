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
    var originalcellAcolor: String?
    var originalcellBimage: UIImage?
    var originalcellBcolor: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchDataAndInitialize()

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let widthConstraint = NSLayoutConstraint(item: collectionView!, attribute: .width, relatedBy: .equal, toItem: nil,attribute: .notAnAttribute, multiplier: 1.0, constant: 400)
        if collectionViewCellWidth > 0  {
            createBorderLines()
        }
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.clipsToBounds = true
        collectionView.isUserInteractionEnabled = true
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
    
        flowlayout.minimumLineSpacing = CGFloat(collectionViewCellSpacing)
        flowlayout.minimumInteritemSpacing = CGFloat(collectionViewCellSpacing)
        
        collectionView.collectionViewLayout = flowlayout
        collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")
        
        collectionView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        collectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewWidth)
        collectionView.delegate = self

        
    }
    
    private func fetchDataAndInitialize() {
        S.delegate_stationList = self
        S.getStationList(gamecode)
        H.delegate_getHost = self
        H.getHost(gamecode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.createGrid()
            self.collectionView.reloadData()
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
        
        // case when considering pvp cases
        guard pvpGameCount >= 0 && pvpGameCount <= grid.count else {
            print("Invalid number of pvp games compared to number of teams")
            return
        }
        
        for rowIndex in stride(from: 1, through:grid.count - 1, by: 2) {
            for i in 0..<(pvpGameCount * 2) {
                grid[rowIndex][i] = -1
            }
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
        
        print("This is my grid: ", grid)
    }

    
    
    //checks each column for duplicates
    func hasDuplicatesInColumn(_ column: Int, in grid: [[Int]]) -> [Int] {
        var existingNumbers = Set<Int>()
        var duplicates = [Int]()
        for row in grid {
            let number = row[column]
            if existingNumbers.contains(number) {
                duplicates.append(number)
            }
            existingNumbers.insert(number)
        }
        return duplicates
    }
    
    //checked the section (row)'s duplicates and callled warning
    func checkAndChangeDuplicatesInRow(section: Int) -> Bool {
        // Get the number of items in the section (row)
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        var existingNumbers = Set<Int>()
        var duplicates = Set<Int>()
        
        var didHaveDuplicate = false
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: section)
            if let cell = collectionView.cellForItem(at: indexPath) as? AlgorithmCollectionViewCell,
               let text = cell.teamnumLabel.text,
               let number = Int(text) {
                if existingNumbers.contains(number) {
                    duplicates.insert(number)
                } else {
                        existingNumbers.insert(number)
                }
            }
        }
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: section)
            if let cell = collectionView.cellForItem(at: indexPath) as? AlgorithmCollectionViewCell,
               let text = cell.teamnumLabel.text,
               let number = Int(text) {
                if duplicates.contains(number) {
                    if let text = cell.teamnumLabel.text, text != "0", text != "-1", text != "" {
                        if cell.warningColor == "orange" || cell.warningColor == "yellow" {
                            cell.makeRedWarning()
                        } else {
                            cell.makePurpleWarning()
                        }
                        didHaveDuplicate = true

   
                    }
                } else {
                    if let text = cell.teamnumLabel.text, text != "0", text != "-1", text != "" {
                        cell.makeCellOriginal()
                    }
                }
            }
        }
        return didHaveDuplicate
    }
    
    func updateCellBackgroundImages() {
        var hadRowDuplicates = false
        for section in 0..<grid.count {
            hadRowDuplicates = checkAndChangeDuplicatesInRow(section: section)
            
            //goes through each rows' columns
            for item in 0..<grid[section].count {
                let column = item
                //array of integers that contains duplicates in column
                let duplicates = hasDuplicatesInColumn(column, in: grid)
                
                if duplicates.contains(grid[section][item]) {
                    if let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? AlgorithmCollectionViewCell {
                        if let text = cell.teamnumLabel.text, text != "0", text != "-1", text != "" {
                            if cell.warningColor == "purple" || cell.warningColor == "yellow" {
                                cell.makeRedWarning()
                            } else {
                                cell.makeOrangeWarning()
                            }
                            

                        }
    
                    }
                } else {
                    // Reset the background image of the cell to nil (no warningImage)
                    if let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? AlgorithmCollectionViewCell {
                        if let text = cell.teamnumLabel.text, text != "0", text != "-1", text != "", !hadRowDuplicates {
                            cell.makeCellOriginal()
                        }

                    }
                }
            }
        }
    }

    
    //checking pvp pair duplicates
    
    func checkPvpDuplicatesAndApplyWarning() {
        // Loop through the pairs of columns based on pvpGameCount
        for pairIndex in 0..<pvpGameCount {
            let columnIndexA = pairIndex * 2
            let columnIndexB = columnIndexA + 1
            
            let duplicatesFound = checkForDuplicatesInPairs(columnIndexA: columnIndexA, columnIndexB: columnIndexB)
            
            if duplicatesFound {
                applyYellowWarningToColumns(columnIndexA: columnIndexA, columnIndexB: columnIndexB)
            }
        }
    }

    func checkForDuplicatesInPairs(columnIndexA: Int, columnIndexB: Int) -> Bool {
        let duplicatesInRows = checkDuplicatesInRows(columnIndexA: columnIndexA, columnIndexB: columnIndexB)
        let duplicatesInColumns = checkDuplicatesInColumns(columnIndexA: columnIndexA, columnIndexB: columnIndexB)
        
        return duplicatesInRows || duplicatesInColumns
    }

    func checkDuplicatesInRows(columnIndexA: Int, columnIndexB: Int) -> Bool {
        var duplicatesFound = false
        for rowIndex in 0..<grid.count {
            if grid[rowIndex][columnIndexA] == grid[rowIndex][columnIndexB] {
                duplicatesFound = true
                break
            }
        }
        return duplicatesFound
    }

    func checkDuplicatesInColumns(columnIndexA: Int, columnIndexB: Int) -> Bool {
        var duplicatesFound = false
        for rowIndex in 0..<grid.count {
            let valueA = grid[rowIndex][columnIndexA]
            let valueB = grid[rowIndex][columnIndexB]
            
            if valueA != -1 && valueB != -1 && valueA != 0 && valueB != 0 && valueA == valueB {
                duplicatesFound = true
                break
            }
        }
        return duplicatesFound
    }

    func applyYellowWarningToColumns(columnIndexA: Int, columnIndexB: Int) {
        for rowIndex in 0..<grid.count {
            let valueA = grid[rowIndex][columnIndexA]
            let valueB = grid[rowIndex][columnIndexB]
            
            if valueA != -1 && valueB != -1 && valueA != 0 && valueB != 0 && valueA == valueB {
                let indexPathA = IndexPath(item: columnIndexA, section: rowIndex)
                let indexPathB = IndexPath(item: columnIndexB, section: rowIndex)
                
                if let cellA = collectionView.cellForItem(at: indexPathA) as? AlgorithmCollectionViewCell {
                    cellA.makeYellowWarning()
                }
                
                if let cellB = collectionView.cellForItem(at: indexPathB) as? AlgorithmCollectionViewCell {
                    cellB.makeYellowWarning()
                }
            }
        }
    }
}


//checking pvp pair duplicates

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

        if indexPathA == nil {
            // First selection
            indexPathA = indexPath
            
            let selectedCellA = collectionView.cellForItem(at: indexPathA!) as? AlgorithmCollectionViewCell
            originalcellAimage = selectedCellA?.algorithmCellBox.image
            originalcellAcolor = selectedCellA?.warningColor

            selectedCellA?.makeCellSelected()

            
        } else if indexPathB == nil {
            // Second selection
            indexPathB = indexPath
            
            
            let selectedCellB = collectionView.cellForItem(at: indexPathB!) as? AlgorithmCollectionViewCell
            originalcellBimage = selectedCellB?.algorithmCellBox.image
            originalcellBcolor = selectedCellB?.warningColor
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

                
                
                self.indexPathA = nil
                self.indexPathB = nil
                self.updateCellBackgroundImages()
                self.checkPvpDuplicatesAndApplyWarning()

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

        
        // configure cells differently based on what it is
        updateCellBackgroundImages()
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

