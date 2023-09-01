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
    
//    private var num_cols : Int = 8
//    private var num_rows : Int = 8
    
    private var gamecode = UserData.readGamecode("gamecode")!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var pvpGameCount : Int = 0
    private var pveGameCount : Int = 0
    
    private var omittedTeamCells = 0
    
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
        
//        let widthConstraint = NSLayoutConstraint(item: collectionView!, attribute: .width, relatedBy: .equal, toItem: nil,attribute: .notAnAttribute, multiplier: 1.0, constant: 400)
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
                bottomCellIndexPath  = IndexPath(item: 0, section: 8 - 1 - verticalEmptyCells)
            }
            if let topAttributes = layout.layoutAttributesForItem(at: topCellIndexPath),
               let bottomAttributes = layout.layoutAttributesForItem(at: bottomCellIndexPath) {
                let length = bottomAttributes.frame.maxY - topAttributes.frame.minY - 3
                return length
            }
        }
        return nil
    }
    
    func hasOmittedTeamCells() -> Int {
        let stationCells = pvpGameCount * 2 + pveGameCount
        let teamCells = num_teams
        
        if teamCells > stationCells {
            print("Be cautious there are omitted Team Cells.")
            return teamCells - stationCells
        }
        return 0
    }
    
    func createGrid() {
        num_stations = pvpGameCount * 2 + pveGameCount

        omittedTeamCells = hasOmittedTeamCells()
        
        if (num_stations < 8) {
            needHorizontalEmptyCells = true
            horizontalEmptyCells = 8 - num_stations
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

        totalcolumn = max(num_stations, num_teams)
        totalrow = num_rounds
        
        for r in 0..<totalrow {
            var currRow: [Int] = []
            
            for t in 0..<totalcolumn {
                var number = (t + (r + 1)) % totalcolumn
                if number == 0 {
                    number = totalcolumn
                }
                

                if excessOf == "stations" || excessOf == "teams" {
                    if t >= totalcolumn - excessCells {
                        if excessOf == "stations" {
                            number = 0
                        } else if excessOf == "teams" {
                            number = -1
                        }
                    }
                }
                
                currRow.append(number)
            }
            
            while currRow.count < 8 {
                currRow.append(-1)
            }
            
            grid.append(currRow)
        }
        
        // case when considering pvp cases
        guard pvpGameCount >= 0 && pvpGameCount <= grid.count / 2 else {
            print("Invalid number of pvp games compared to number of teams")
            return
        }
        
        for rowIndex in stride(from: 1, through:grid.count - 1, by: 2) {
            for i in 0..<(pvpGameCount * 2) {
                if grid[rowIndex][i]  != -1 {
                    grid[rowIndex][i] = 0
                }
            }
        }


        
        print("This is my grid: ", grid)
       grid = [[1, 2, 3, 4, 5, 6, 7, -1], [0, 0, 0, 0, 6, 7, 1, -1], [3, 4, 5, 6, 7, 1, 2, -1], [0, 0, 0, 0, 1, 2, 3, -1], [5, 6, 7, 1, 4, 3, 4, -1], [0, 0, 0, 0, 2, 4, 5, -1], [7, 1, 2, 3, 4, 5, 6, -1]]
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
    func checkAndChangeDuplicatesInRow(section: Int) -> [Int] {
        // Get the number of items in the section (row)
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        var existingNumbers = Set<Int>()
        var duplicates = [Int]()
        
        //new//
        var indexPathsToStore: [IndexPath] = []
        
        //new//
        
//        var didHaveDuplicate = false
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: section)
//            print(indexPath, "<----- INDEXPATH   "  )
//            let validity = isIndexPathValid(indexPath)
//            print(validity)
            let number = grid[section][item]
            
            if existingNumbers.contains(number) {
                if number != 0 && number != -1 {
                    duplicates.append(number)
//                    didHaveDuplicate = true
                    //new//
                    indexPathsToStore.append(indexPath)
                    //new//
                }
                
            } else {
                existingNumbers.insert(number)
                
            }
            
        }
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: section)

            if let cell = collectionView.cellForItem(at: indexPath) as? AlgorithmCollectionViewCell,
               let number = cell.number {
                if duplicates.contains(number) {
                    if let text = cell.teamnumLabel.text, text != "0", text != "-1", text != "" {
                        
                        //here new code

                        let scannedRed = scanItems(inColumn: item, with: number, until: section)
//                        print("checkandchange duplicates after scanning red for : " , number)

                        if scannedRed {
                            cell.makeRedWarning()
                        } else {
                            cell.makePurpleWarning()
                        }
                        //here new code
                        
                    }
                }
            }
        }
        return duplicates
    }
    
    
    func isIndexPathValid(_ indexPath: IndexPath) -> Bool {
        let numberOfSections = collectionView.numberOfSections
        let numberOfItemsInSection = collectionView.numberOfItems(inSection: indexPath.section)
        
        let isSectionValid = indexPath.section >= 0 && indexPath.section < numberOfSections
        let isItemValid = indexPath.item >= 0 && indexPath.item < numberOfItemsInSection
        
        return isSectionValid && isItemValid
    }

    func scanForRedHorizontally(inRow section: Int, with targetNumber: Int) -> Bool {
        var foundRedCell = false
        let indexPathsInSection = collectionView.indexPathsForVisibleItems.filter { $0.section == section }
        
        for indexPath in indexPathsInSection {
            if let cell = collectionView.cellForItem(at: indexPath) as? AlgorithmCollectionViewCell {
                if cell.number == targetNumber && cell.warningColor == "red"{
                    foundRedCell = true
                }
            }
        }
        return foundRedCell
    }
    
    func scanForRedVertically(inColumn column: Int, with targetNumber: Int) -> Bool {
        var foundRedCell = false
        let sections = collectionView.numberOfSections
        
        for section in 0..<sections {
            let indexPath = IndexPath(item: column, section: section)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? AlgorithmCollectionViewCell,
              let number = cell.number {
                if number == targetNumber && cell.warningColor == "red" {
                    foundRedCell = true
                }
            }
        }
        return foundRedCell
    }
    
    func scanItems(inRow section: Int, with targetNumber: Int, until stopColumn: Int) -> Bool {
        var scannedRed = false
        let indexPathsInSection = collectionView.indexPathsForVisibleItems.filter { $0.section == section }
        
        for indexPath in indexPathsInSection {
            if let cell = collectionView.cellForItem(at: indexPath) as? AlgorithmCollectionViewCell {
                if cell.number == targetNumber && indexPath.item != stopColumn{
                    cell.makeRedWarning()
                    scannedRed = true
                    _ = scanItems(inColumn: indexPath.item, with: targetNumber, until: section)
                } else if cell.number == targetNumber && cell.warningColor == "yellow" {
                    // have to check the column next toit
                }
            }
        }
        return scannedRed
    }
    
    func scanItems(inColumn column: Int, with targetNumber: Int, until stopSection: Int) -> Bool{
        var scannedRed = false
        let sections = collectionView.numberOfSections
        
        for section in 0..<sections {
            let indexPath = IndexPath(item: column, section: section)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? AlgorithmCollectionViewCell {
                if cell.number == targetNumber && section != stopSection {
                    cell.makeRedWarning()
                    scannedRed = true
                    _ = scanItems(inRow: section, with: targetNumber, until: column)
                } else if cell.number == targetNumber && cell.warningColor == "yellow" {
                    // have to check the column next to it
                }
            }
        }
        return scannedRed
    }
                   
    
    func updateEncounteredSameTeam() {
        
    }
    
    func updateCellBackgroundImages() {
        var hadRowDuplicates = false
        for section in 0..<grid.count {
            let rowDuplicates = checkAndChangeDuplicatesInRow(section: section)
            hadRowDuplicates = !rowDuplicates.isEmpty
            
            //goes through each rows' columns
            for item in 0..<grid[section].count {
                let column = item
                //array of integers that contains duplicates in column
                let duplicates = hasDuplicatesInColumn(column, in: grid)
                
                if duplicates.contains(grid[section][item]) {
                    if let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? AlgorithmCollectionViewCell {
                        if let text = cell.teamnumLabel.text, text != "0", text != "-1", text != "" {
                            
                            let scannedRed = scanItems(inRow:section, with: cell.number!, until: column)
                            if scannedRed || scanForRedVertically(inColumn: column, with: cell.number!) {
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
    
    func findPvpDuplicates() -> [[Int]] {
        var duplicatesArray: [[Int]] = []
        
        for pairIndex in 0..<pvpGameCount {
            let startColumn = pairIndex * 2
            let endColumn = startColumn + 1
            
            var seenValues: Set<Int> = []
            var duplicateValues: Set<Int> = []
            
            for rowIndex in 0..<grid.count {
                let row = grid[rowIndex]
                
                if startColumn < row.count, endColumn < row.count {
                    let firstValue = row[startColumn]
                    let secondValue = row[endColumn]
                    

                        
                        if seenValues.contains(firstValue) && firstValue != 0, firstValue != -1 {
                            duplicateValues.insert(firstValue)
                        } else {
                            seenValues.insert(firstValue)
                        }
                        
                        if seenValues.contains(secondValue) && secondValue != 0, secondValue != -1 {
                            duplicateValues.insert(secondValue)
                        } else {
                            seenValues.insert(secondValue)
                        }
                    
                }
            }
            
            if duplicateValues.isEmpty {
                duplicatesArray.append([])
            } else {
                duplicatesArray.append(Array(duplicateValues))
            }
        }
        
        return duplicatesArray
    }

    
    func updatePvpCellDuplicates(_ duplicates: [[Int]]) {
        for (pairIndex, duplicateValues) in duplicates.enumerated() {
            let startColumn = pairIndex * 2
            let endColumn = startColumn + 1
            
            for value in duplicateValues {
                for section in 0..<collectionView.numberOfSections {
                    let indexPathStartColumn = IndexPath(item: startColumn, section: section)
                    let indexPathEndColumn = IndexPath(item: endColumn, section: section)
                    
                    if grid[indexPathStartColumn.section][indexPathStartColumn.item] == value {
                        let cell = collectionView.cellForItem(at: indexPathStartColumn) as? AlgorithmCollectionViewCell
                        cell?.makeOrangeWarning()
                    }
                    
                    if grid[indexPathEndColumn.section][indexPathEndColumn.item] == value {
                        let cell = collectionView.cellForItem(at: indexPathEndColumn) as? AlgorithmCollectionViewCell
                        cell?.makeOrangeWarning()
                    }
                }
            }
        }
    }
    
    func resetAll() {
        if let indexPaths = collectionView.indexPathsForSelectedItems, !indexPaths.isEmpty {
            for indexPath in indexPaths {
                self.collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                if let cell = collectionView.cellForItem(at: indexPath) as? AlgorithmCollectionViewCell {
                    if cell.visible == true {
                        cell.makeCellOriginal()
                    }
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
        print("Selected cell at IndexPath: \(indexPath)")
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
                selectedCellA?.makeCellImageOriginal()
                selectedCellB?.makeCellImageOriginal()
                
                self.indexPathA = nil
                self.indexPathB = nil
                
                print("RESET!______________")
                self.resetAll()

                self.updateCellBackgroundImages()
                print("FIND PVP DUPLICATES : ", self.findPvpDuplicates())
                self.updatePvpCellDuplicates(self.findPvpDuplicates())


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

        
        if teamNumberLabel == -1 {
            cell.makeCellInvisible()
        } else if teamNumberLabel == 0 {
            cell.makeCellEmpty()
        }else {
            cell.configureAlgorithmNormalCell(cellteamnum : teamNumberLabel)
        }
        resetAll()
        updateCellBackgroundImages()
        updatePvpCellDuplicates(findPvpDuplicates())
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
        return cellNumber == -1
    }


    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? AlgorithmCollectionViewCell else { return }
        
        if !cell.isSelected {
            
                let alertController = UIAlertController(title: "Enter the team number", message: nil, preferredStyle: .alert)
                alertController.addTextField { textField in
                textField.keyboardType = .numberPad
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                cell.isSelected = false
                alertController.dismiss(animated: true, completion: nil)
            }))
        
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if let numberString = alertController.textFields?.first?.text,
                let number = Int(numberString) {
                
                    cell.teamnumLabel.text = "\(number)"
                    if number == 0 {
                        cell.makeCellEmpty()
                    }
                
                    if let indexPath = self.collectionView.indexPath(for: cell) {
                        let section = indexPath.section
                        let item = indexPath.item
                        self.grid[section][item] = number
                    }
                    self.resetAll()
                    self.updateCellBackgroundImages()
                    self.updatePvpCellDuplicates(self.findPvpDuplicates())
                    cell.isSelected = false
                }
            
                alertController.dismiss(animated: true, completion: nil)
            }))
            present(alertController, animated: true, completion: nil)
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

