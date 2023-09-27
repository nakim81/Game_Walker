//
//  AlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/22.
//


//import UIKit
//
//class AlgorithmViewController: BaseViewController {
//    
//    @IBOutlet weak var startGameButton: UIButton!
//    private var stationList: [Station]? = nil
//    private var grid: [[Int]] = [[Int]]()
//    private var cellDataGrid : [[CellData]] = [[CellData]]()
//    private var totalrow : Int =  0
//    private var totalcolumn : Int = 0
//    
//    private var num_rounds : Int = 0
//    private var num_teams : Int = 0
//    private var num_stations : Int = 0
//    
//    
//    private var needHorizontalEmptyCells = false
//    private var needVerticalEmptyCells = false
//    private var horizontalEmptyCells = 0
//    private var verticalEmptyCells = 0
//    //options: "none", "teams", "stations"
//    private var excessOf = "none"
//    private var excessCells = 0
//    
//    
//    private var collectionViewWidth = UIScreen.main.bounds.width * 0.85
//    private var collectionViewCellWidth : Int = 0
//    private var collectionViewCellSpacing = 4
//    
//    private var gamecode = UserData.readGamecode("gamecode")!
//    
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var collectionView: UICollectionView!
//    
//    private var pvpGameCount : Int = 0
//    private var pveGameCount : Int = 0
//    
//    private var omittedTeamCells = 0
//    
////    var indexPathA: IndexPath?
////    var indexPathB: IndexPath?
//    
//    var cellDataA : CellData?
//    var cellDataB : CellData?
//    
//    var originalcellAimage: UIImage?
//    var originalcellAcolor: String?
//    var originalcellBimage: UIImage?
//    var originalcellBcolor: String?
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionView()
//        fetchDataAndInitialize()
//        
//    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if collectionViewCellWidth > 0  {
//            createBorderLines()
//        }
//    }
//    
//    private func setupCollectionView() {
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        
//        collectionView.clipsToBounds = true
//        collectionView.isUserInteractionEnabled = true
//        
//        let flowlayout = UICollectionViewFlowLayout()
//        flowlayout.scrollDirection = .vertical
//        
//        flowlayout.minimumLineSpacing = CGFloat(collectionViewCellSpacing)
//        flowlayout.minimumInteritemSpacing = CGFloat(collectionViewCellSpacing)
//        
//        collectionView.collectionViewLayout = flowlayout
//        collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")
//        
//        collectionView.isScrollEnabled = true
//        scrollView.isUserInteractionEnabled = true
//        scrollView.isScrollEnabled = true
//        collectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewWidth)
//        collectionView.delegate = self
//        
//        
//    }
//    
//    private func fetchDataAndInitialize() {
//
//        
//        Task { @MainActor in
//            do {
//                stationList = try await S.getStationList2(gamecode)
//                self.num_stations = stationList!.count
//                self.collectionView?.reloadData()
//                var pvpCount = 0
//                
//                if let unwrappedStationList = stationList {
//                    for station in unwrappedStationList {
//                        if station.pvp {
//                            pvpCount += 1
//                        }
//                    }
//                }
//                
//                self.pvpGameCount = pvpCount
//                self.pveGameCount = stationList!.count - pvpCount
//                
//            } catch(let e) {
//                print(e)
//                return
//            }
//        }
////        H.delegate_getHost = self
////        H.getHost(gamecode)
//        Task { @MainActor in
//            do {
//                let host = try await H.getHost2(gamecode)
//                self.num_teams = host!.teams
//                self.num_rounds = host!.rounds
//                self.collectionView?.reloadData()
//                
//            } catch(let e) {
//                print(e)
//                return
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.createGrid()
//            self.reloadAll()
//            self.collectionView.reloadData()
//        }
//    }
//    
//    @IBAction func startGameButtonPressed(_ sender: UIButton) {
////        alert2(title: "", message: "Everything set?")
//        let startGameViewController = StartGameViewController(announcement: "Once the game is created, you won't be able to change the game settings", source: "", gamecode: gamecode)
//        startGameViewController.delegate = self
//        present(startGameViewController, animated: true)
//    }
//    
//    func createBorderLines() {
//        
//        var positions: [(Int, Int)] = []
//        
//        for i in 0..<pvpGameCount {
//            let one = i * 2 + 1
//            let two = i * 2 + 2
//            positions.append((one, two))
//        }
//        
//        for position in positions {
//            let first = position.0
//            let second = position.1
//            
//            let borderView = VerticalBorderView(frame: CGRect(x: Int(getLinePosition(firstColumn: first, secondColumn: second) ?? 0), y: 3, width: 2, height: Int(getLineLength(smallerThanEight: needVerticalEmptyCells)!)))
//            collectionView.addSubview(borderView)
//        }
//    }
//    
//    func getLinePosition(firstColumn: Int, secondColumn: Int ) -> CGFloat? {
//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            let indexPath1 = IndexPath(item: firstColumn, section: 0)
//            let indexPath2 = IndexPath(item: secondColumn, section: 0)
//            
//            if let attributes1 = layout.layoutAttributesForItem(at: indexPath1),
//               let attributes2 = layout.layoutAttributesForItem(at: indexPath2) {
//                let midpointX = (attributes1.frame.midX + attributes2.frame.midX) / 2.0
//                return midpointX
//            }
//        }
//        return nil
//    }
//    
//    func getLineLength(smallerThanEight: Bool) -> CGFloat? {
//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            let topCellIndexPath = IndexPath(item: 0, section: 0)
//            var bottomCellIndexPath = IndexPath(item: 0, section: collectionView.numberOfSections - 1)
//            if smallerThanEight {
//                bottomCellIndexPath  = IndexPath(item: 0, section: 8 - 1 - verticalEmptyCells)
//            }
//            if let topAttributes = layout.layoutAttributesForItem(at: topCellIndexPath),
//               let bottomAttributes = layout.layoutAttributesForItem(at: bottomCellIndexPath) {
//                let length = bottomAttributes.frame.maxY - topAttributes.frame.minY - 3
//                return length
//            }
//        }
//        return nil
//    }
//    
//    func hasOmittedTeamCells() -> Int {
//        let stationCells = pvpGameCount * 2 + pveGameCount
//        let teamCells = num_teams
//        
//        if teamCells > stationCells {
//            print("Be cautious there are omitted Team Cells.")
//            return teamCells - stationCells
//        }
//        return 0
//    }
//    
//    func createGrid() {
//        num_stations = pvpGameCount * 2 + pveGameCount
//
//        omittedTeamCells = hasOmittedTeamCells()
//        
//        if (num_stations < 8) {
//            needHorizontalEmptyCells = true
//            horizontalEmptyCells = 8 - num_stations
//        }
//        
//        if (num_rounds < 8) {
//            needVerticalEmptyCells = true
//            verticalEmptyCells = 8 - num_rounds
//        }
//        if (num_stations < num_teams) {
//            excessOf = "teams"
//            excessCells = num_teams - num_stations
//        }
//        if (num_teams < num_stations) {
//            excessOf = "stations"
//            excessCells = num_stations - num_teams
//        }
//
//        totalcolumn = max(num_stations, num_teams)
//        totalrow = num_rounds
//        
//        for r in 0..<totalrow {
//            var currRow: [Int] = []
//            
//            // adding grid with celldata
//            var currCellDataRow: [CellData] = []
//            
//            for t in 0..<totalcolumn {
//                var number = (t + (r + 1)) % totalcolumn
//                if number == 0 {
//                    number = totalcolumn
//                }
//                
//
//                var visible = true
//                if excessOf == "stations" || excessOf == "teams" {
//                    if t >= totalcolumn - excessCells {
//                        if excessOf == "stations" {
//                            number = 0
//                        } else if excessOf == "teams" {
//                            number = -1
//                            visible = false
//                        }
//                    }
//                }
//                let celldata = CellData(number: number, visible: visible, index: IntPair(first: r, second: t))
//                currRow.append(number)
//                currCellDataRow.append(celldata)
//            }
//            
//            while currRow.count < 8 {
//                currRow.append(-1)
//                let celldata = CellData(number: -1, visible: false, index: IntPair(first:r, second:currRow.count))
//                currCellDataRow.append(celldata)
//            }
//            
//            grid.append(currRow)
//            cellDataGrid.append(currCellDataRow)
//        }
//        
//        
//        for rowIndex in stride(from: 1, through: cellDataGrid.count - 1, by: 2) {
//            for column in 0..<(pvpGameCount * 2) {
//                if grid[rowIndex][column]  != -1 {
//                grid[rowIndex][column] = 0
//                }
//                
//                let cellData = cellDataGrid[rowIndex][column]
//                if cellData.number != -1 {
//                    changeCellGridData(cellDataInstance: cellData, to: "empty")
//                }
//            }
//        }
//        
//
//        
//        print("This is my grid: ", grid)
//        print("This is my cellDataGrid: ", cellDataGrid)
//    }
//    
//    
//    
//    //checks each column for duplicates
//    func hasDuplicatesInColumn(_ column: Int, in grid: [[CellData]]) -> [Int] {
//        var existingNumbers = Set<Int>()
//        var duplicates = [Int]()
//        for row in grid {
//            let number = row[column].number
//            if existingNumbers.contains(number!) {
//                duplicates.append(number!)
//            }
//            existingNumbers.insert(number!)
//        }
//        return duplicates
//    }
//    
//    //checked the section (row)'s duplicates and callled warning
//    func checkAndChangeDuplicatesInRow(section: Int) -> [Int] {
//        // Get the number of items in the section (row)
//        let numberOfItems = cellDataGrid[section].count
//        var existingNumbers = Set<Int>()
//        var duplicates = [Int]()
//        
//        for item in 0..<numberOfItems {
//            let cellData = cellDataGrid[section][item]
//            let number = cellData.number
//            
//            if existingNumbers.contains(number!) {
//                if numberIsValid(number) {
//                    duplicates.append(number!)
//                }
//            } else {
//                existingNumbers.insert(number!)
//            }
//        }
//        
//        var scannedRedAlready = false
//        for item in 0..<numberOfItems {
//            let cellData = cellDataGrid[section][item]
//            let number = cellData.number
//            if duplicates.contains(number!) && numberIsValid(number){
//                let scannedRed = scanItems(inColumn: item, with: number!, until: section)
//                
//                if scannedRed || scannedRedAlready {
//                    scannedRedAlready = true
//                    changeCellGridData(cellDataInstance: cellData, to: "red")
//                } else {
//                    changeCellGridData(cellDataInstance: cellData, to: "purple")
//                }
//            }
//        }
//        return duplicates
//    }
//    
//    
//    func isIndexPathValid(_ indexPath: IndexPath) -> Bool {
//        let numberOfSections = collectionView.numberOfSections
//        let numberOfItemsInSection = collectionView.numberOfItems(inSection: indexPath.section)
//        
//        let isSectionValid = indexPath.section >= 0 && indexPath.section < numberOfSections
//        let isItemValid = indexPath.item >= 0 && indexPath.item < numberOfItemsInSection
//        
//        return isSectionValid && isItemValid
//    }
//
//    
//    func scanForRedVertically(inColumn column: Int, with targetNumber: Int) -> Bool {
//        var foundRedCell = false
//        let sections = cellDataGrid.count
//        
//        for section in 0..<sections {
//            let cellData = cellDataGrid[section][column]
//            let number = cellData.number
//            if number == targetNumber && cellData.warningColor == "red" {
//                foundRedCell = true
//            }
//        }
//        return foundRedCell
//    }
//    
//    func scanItems(inRow section: Int, with targetNumber: Int, until stopColumn: Int) -> Bool {
//        var scannedRed = false
////        let indexPathsInSection = collectionView.indexPathsForVisibleItems.filter { $0.section == section }
//        
//        for cellData in cellDataGrid[section] {
//            let number = cellData.number
//            let column = cellData.cellIndex?.second
//            if number == targetNumber && column != stopColumn {
//                changeCellGridData(cellDataInstance: cellData, to: "red")
//                scannedRed = true
//                _ = scanItems(inColumn: column!, with: targetNumber, until: section)
//            } else if number == targetNumber && cellData.hasPvpYellowWarning {
//                changeCellGridData(cellDataInstance: cellData, to: "red")
//                for yellowCellData in cellData.cellsWithSameYellowPvpWarning {
//                    changeCellGridData(cellDataInstance: yellowCellData, to: "red")
//                    scannedRed = true
//                }
//            } else if number == targetNumber && cellData.hasPvpBlueWarning {
//                changeCellGridData(cellDataInstance: cellData, to: "red")
//                for blueCellData in cellData.cellsWithSameBluePvpWarning {
//                    changeCellGridData(cellDataInstance: blueCellData, to: "red")
//                    scannedRed = true
//                }
//            }
//            
//        }
//        return scannedRed
//    }
//    
//    func scanItems(inColumn column: Int, with targetNumber: Int, until stopSection: Int) -> Bool{
//        var scannedRed = false
//        
//        for section in 0..<cellDataGrid.count {
//            let cellData = cellDataGrid[section][column]
//            let number = cellData.number
//            
//            if number == targetNumber && section != stopSection {
//                changeCellGridData(cellDataInstance: cellData, to: "red")
//                scannedRed = true
//                
//                _ = scanItems(inRow: section, with: targetNumber, until: column)
//            } else if number == targetNumber && cellData.hasPvpYellowWarning {
//                changeCellGridData(cellDataInstance: cellData, to: "red")
//                scannedRed = true
//                for yellowCellData in cellData.cellsWithSameYellowPvpWarning {
//                    changeCellGridData(cellDataInstance: yellowCellData, to: "red")
//                }
//            } else if number == targetNumber && cellData.hasPvpBlueWarning {
//                changeCellGridData(cellDataInstance: cellData, to: "red")
//                scannedRed = true
//                for blueCellData in cellData.cellsWithSameBluePvpWarning {
//                    changeCellGridData(cellDataInstance: blueCellData, to: "red")
//                }
//            }
//        }
//        return scannedRed
//    }
//
//    func updateCellBackgroundImages() {
////        var hadRowDuplicates = false
//        for section in 0..<cellDataGrid.count {
//            let rowDuplicates = checkAndChangeDuplicatesInRow(section: section)
////            hadRowDuplicates = !rowDuplicates.isEmpty
//            
//            //goes through each rows' columns
//            for item in 0..<cellDataGrid[section].count {
//                let column = item
//                //array of integers that contains duplicates in column
//                let duplicates = hasDuplicatesInColumn(column, in: cellDataGrid)
//                
//                if duplicates.contains(cellDataGrid[section][item].number!) {
//                    let cellData = cellDataGrid[section][item]
//                    let number = cellData.number
//                    if numberIsValid(number) {
//                        let scannedRed = scanItems(inRow: section, with: number!, until: column)
//                        
//                        if scannedRed || scanForRedVertically(inColumn: column, with: number!) {
//                            changeCellGridData(cellDataInstance: cellData, to: "red")
//                        } else {
//                            changeCellGridData(cellDataInstance: cellData, to: "yellow")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//       
//    func numberIsValid(_ number: Int?) -> Bool {
//        if number != nil && number != 0 && number != -1 {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func processPvpBlueCells() {
//        print("PROCESS PVP BLUE CELLS")
//        var numbersSeenByNumber = [Int: Set<Int>]()
//        var duplicatedPairs = Set<IntPair>()
//        for pairIndex in 0...(pvpGameCount - 1) {
//            let startColumn = pairIndex * 2
//            let endColumn = startColumn + 1
//            
//            for section in 0..<cellDataGrid.count {
//                    let cellData1 = cellDataGrid[section][startColumn]
//                    let cellData2 = cellDataGrid[section][endColumn]
//                    let numberKey1 = cellData1.number
//                    let numberKey2 = cellData2.number
//                    
//                    if numberIsValid(numberKey1) {
//                        if var seenNumbers = numbersSeenByNumber[numberKey1!] {
//                            if numberIsValid(numberKey2) {
//                                if seenNumbers.contains(numberKey2!) {
//                                    duplicatedPairs.insert(IntPair(first: numberKey1!, second: numberKey2!))
//                                } else {
//                                    seenNumbers.insert(numberKey2!)
//                                    numbersSeenByNumber[numberKey1!] = seenNumbers
//                                    if var seenNumbersPair = numbersSeenByNumber[numberKey2!]{
//                                        if numberIsValid(numberKey1) {
//                                            if !seenNumbersPair.contains(numberKey1!) {
//                                                seenNumbersPair.insert(numberKey1!)
//                                                numbersSeenByNumber[numberKey2!] = seenNumbersPair
//                                            }
//                                        }
//                                    } else {
//                                        var newNumberSet = Set<Int>()
//                                        newNumberSet.insert(numberKey1!)
//                                        numbersSeenByNumber[numberKey2!] = newNumberSet
//                                    }
//                                }
//                            }
//                        } else {
//                            if numberIsValid(numberKey2) {
//                                var newNumberSet1 = Set<Int>()
//                                var newNumberSet2 = Set<Int>()
//                                newNumberSet1.insert(numberKey2!)
//                                numbersSeenByNumber[numberKey1!] = newNumberSet1
//                                newNumberSet2.insert(numberKey1!)
//                                numbersSeenByNumber[numberKey2!] = newNumberSet2
//                            }
//                        }
//                    }
//            }
//        }
//        makeAllDuplicatePairsBlue(duplicatedPairs)
//    }
//    
//    func makeAllDuplicatePairsBlue(_ duplicatedPairs : Set<IntPair>) {
////        print(duplicatedPairs, "DUPLICATEDPAIRS")
//        
//        var allCellsWithDuplicatedMatchesByPairs = [IntPair: Set<CellData>]()
//        
//        for pairIndex in 0...(pvpGameCount-1) {
//            let evenColumn = pairIndex * 2
//            for section in 0..<cellDataGrid.count {
//                
//                let cellData1 = cellDataGrid[section][evenColumn]
//                let cellData2 = getCellCurrPlayingWith(cellData1)
//                let number1 = cellData1.number
//                let number2 = cellData2.number
//                
//                // indexPathsByPairs with have the same IntPair value for either switched or not switched pairs.
//                // example: IntPair(1,2) and IntPair(2,1) will have the Key of IntPair(1,2)
//                let currPair = IntPair(first: number1!, second: number2!)
//                let currPairSwitched = currPair.switchPair(currPair)
//                let currPairKey = currPair.cleanOrderPair(currPair)
//                
//                if duplicatedPairs.contains(currPair) || duplicatedPairs.contains(currPairSwitched) {
//                    if var cellDataSet = allCellsWithDuplicatedMatchesByPairs[currPairKey] {
//                        cellDataSet.insert(cellData1)
//                        cellDataSet.insert(cellData2)
//                        allCellsWithDuplicatedMatchesByPairs[currPairKey] = cellDataSet
//                    } else {
//                        var newCellDataSet = Set<CellData>()
//                        newCellDataSet.insert(cellData1)
//                        newCellDataSet.insert(cellData2)
//                        allCellsWithDuplicatedMatchesByPairs[currPairKey] = newCellDataSet
//                    }
//                }
//            }
//        }
//        
//        for (_, cellDataSet) in allCellsWithDuplicatedMatchesByPairs {
//            for cellData in cellDataSet {
//                addCellSetsToCellGridData(cellDataInstance: cellData, to: "blue", set: cellDataSet)
//                
//                //Case where cells that need blue warnings already has yellow pvp warnings
//                if cellData.hasPvpYellowWarning {
//                    changeCellGridData(cellDataInstance: cellData, to: "red")
//                    for yellowCellData in cellData.cellsWithSameYellowPvpWarning {
//                        changeCellGridData(cellDataInstance: yellowCellData, to: "red")
//                    }
//                    for currCellData in cellData.cellsWithSameBluePvpWarning {
//                        changeCellGridData(cellDataInstance: currCellData, to: "red")
//                    }
//                } else if cellData.hasPurpleWarning {
//                    for purpleCellData in cellData.cellsWithSamePurpleWarning {
//                        changeCellGridData(cellDataInstance: purpleCellData, to: "red")
//                    }
//                    for currCellData in cellData.cellsWithSameBluePvpWarning {
//                        changeCellGridData(cellDataInstance: currCellData, to: "red")
//                    }
//                } else if cellData.hasYellowWarning{
//                    for yellowCellData in cellData.cellsWithSameYellowWarning {
//                        changeCellGridData(cellDataInstance: yellowCellData, to: "red")
//                    }
//                    for currCellData in cellData.cellsWithSameBluePvpWarning {
//                        changeCellGridData(cellDataInstance: currCellData, to: "red")
//                    }
//                } else if cellData.hasRedWarning {
//                    for currCellData in cellData.cellsWithSameBluePvpWarning {
//                        changeCellGridData(cellDataInstance: currCellData, to: "red")
//                    }
//                }else {
//                    changeCellGridData(cellDataInstance: cellData, to: "blue")
//                    print("changing a pvp blue cell to blue. no other error encountered")
//                }
//            }
//        }
//    }
//    
//                              
//    func getCellCurrPlayingWith(_ cellData: CellData) -> CellData {
//        if cellData.cellIndex!.second % 2 == 0 {
//            return cellDataGrid[cellData.cellIndex!.first][cellData.cellIndex!.second + 1]
//        } else {
//            return cellDataGrid[cellData.cellIndex!.first][cellData.cellIndex!.second - 1]
//        }
//    }
//    
//                           
//                            
//    func processPvpYellowCells () {
//
//        for pairIndex in 0..<pvpGameCount {
//            let startColumn = pairIndex * 2
//            let endColumn = startColumn + 1
//            
//            var matchedCellsByNumber = [Int: Set<CellData>]()
//
//            for section in 0..<cellDataGrid.count {
//                for column in startColumn...endColumn {
//                    let cellData = cellDataGrid[section][column]
//                    let numberKey = cellData.number
//                        
//                    if numberIsValid(numberKey) {
//                        //Checking if IntPairsByNumbers already has the numberkey
//                        if var cellDataSet = matchedCellsByNumber[numberKey!] {
//                            cellDataSet.insert(cellData)
//                            matchedCellsByNumber[numberKey!] = cellDataSet
//                        } else {
//                            var newCellDataSet = Set<CellData>()
//                            newCellDataSet.insert(cellData)
//                            matchedCellsByNumber[numberKey!] = newCellDataSet
//                        }
//                    }
//                    
//                }
//            }
//            // Check number keys with multiple cells.
//            // This will tell if there are duplicates in the two pvp column pairs.
//            for (_, cellDataset) in matchedCellsByNumber {
//                if cellDataset.count >= 2 {
//                    for cellData in cellDataset {
//                        changeCellGridData(cellDataInstance: cellData, to: "yellowPvp")
//                        addCellSetsToCellGridData(cellDataInstance: cellData, to: "yellowPvp", set: cellDataset)
//                    }
//                }
//            }
//        }
//    }
//    
//    func processPurpleSameRoundCells() {
//        for row in cellDataGrid {
//            var rowNumbers = [Int: Set<CellData>]()
//            for cellData in row {
//                let number = cellData.number
//                
//                if numberIsValid(number) {
//                    if var cellDataSet = rowNumbers[number!] {
//                        cellDataSet.insert(cellData)
//                        rowNumbers[number!] = cellDataSet
//                    } else {
//                        var newCellDataSet = Set<CellData>()
//                        newCellDataSet.insert(cellData)
//                        rowNumbers[number!] = newCellDataSet
//                    }
//                }
//            }
//            //Now mark each cell with more than two counts in sets in each row
//            for (_, cellDataSet) in rowNumbers {
//                if cellDataSet.count >= 2 {
//                    for cellDataDuplicates in cellDataSet {
//                        addCellSetsToCellGridData(cellDataInstance: cellDataDuplicates, to: "purple", set: cellDataSet)
//                        
//                        if cellDataDuplicates.hasRedWarning {
//                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "red")
//                        } else if cellDataDuplicates.hasPvpBlueWarning {
//                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "red")
//                            for pvpBlueCellData in cellDataDuplicates.cellsWithSameBluePvpWarning {
//                                changeCellGridData(cellDataInstance: pvpBlueCellData, to: "red")
//                            }
//                            for currCellData in cellDataDuplicates.cellsWithSamePurpleWarning   {
//                                changeCellGridData(cellDataInstance: currCellData, to: "red")
//                            }
//                        } else if cellDataDuplicates.hasPvpYellowWarning {
//                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "red")
//                            for pvpYellowCellData in cellDataDuplicates.cellsWithSameYellowPvpWarning {
//                                changeCellGridData(cellDataInstance: pvpYellowCellData, to: "red")
//                            }
//                            for currCellData in cellDataDuplicates.cellsWithSamePurpleWarning   {
//                                changeCellGridData(cellDataInstance: currCellData, to: "red")
//                            }
//                        } else {
//                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "purple")
//                        }
//
//                    }
//                }
//            }
//        }
//    }
//    
//    func processYellowSameStationCells() {
//        print("PROCESS YELLOW SAME STATION CELLS")
//        for col in 0..<cellDataGrid[0].count {
//            var columnNumbers = [Int: Set<CellData>]()
//            for sect in 0..<cellDataGrid.count {
//                let cellData = cellDataGrid[sect][col]
//                let number = cellData.number
//                
//                if numberIsValid(number) {
//                    if var cellDataSet = columnNumbers[number!] {
//                        cellDataSet.insert(cellData)
//                        columnNumbers[number!] = cellDataSet
//                    } else {
//                        var newCellDataSet = Set<CellData>()
//                        newCellDataSet.insert(cellData)
//                        columnNumbers[number!] = newCellDataSet
//                    }
//                }
//            }
//            for (_, cellDataSet) in columnNumbers {
//                if cellDataSet.count >= 2 {
//                    for cellDataWithWarning in cellDataSet {
//                        addCellSetsToCellGridData(cellDataInstance: cellDataWithWarning, to: "yellow", set: cellDataSet)
//                        if cellDataWithWarning.hasPurpleWarning {
//                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
//                            for purpleCellData in cellDataWithWarning.cellsWithSamePurpleWarning {
//                                changeCellGridData(cellDataInstance: purpleCellData, to: "red")
//                            }
//                            for currCellData in cellDataWithWarning.cellsWithSameYellowWarning   {
//                                changeCellGridData(cellDataInstance: currCellData, to: "red")
//                            }
//                        } else if cellDataWithWarning.hasRedWarning {
//                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
//                            
//                        } else if cellDataWithWarning.hasPvpBlueWarning {
//                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
//                            for pvpBlueCellData in cellDataWithWarning.cellsWithSameBluePvpWarning {
//                                changeCellGridData(cellDataInstance: pvpBlueCellData, to: "red")
//                            }
//                            for currCellData in cellDataWithWarning.cellsWithSameYellowWarning   {
//                                changeCellGridData(cellDataInstance: currCellData, to: "red")
//                            }
//                        } else if cellDataWithWarning.hasPvpYellowWarning {
////                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
////                            for pvpYellowCellData in cellDataWithWarning.cellsWithSameYellowPvpWarning {
////                                changeCellGridData(cellDataInstance: pvpYellowCellData, to: "red")
////                            }
//                        } else {
//                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "yellow")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func changeCellGridData(cellDataInstance: CellData, to state: String) {
//        let section = cellDataInstance.cellIndex?.first
//        let column = cellDataInstance.cellIndex?.second
//        cellDataGrid[section!][column!].changeState(to: state)
//    }
//    
//    func addCellSetsToCellGridData(cellDataInstance: CellData, to color: String, set: Set<CellData>) {
//        let section = cellDataInstance.cellIndex?.first
//        let column = cellDataInstance.cellIndex?.second
//        if color == "blue" {
//            cellDataGrid[section!][column!].addBluePvpIndexToCellData(set)
//        } else if color == "yellowPvp" {
//            cellDataGrid[section!][column!].addYellowPvpIndexToCellData(set)
//        } else if color == "yellow" {
//            cellDataGrid[section!][column!].addYellowIndexToCellData(set)
//        } else if color == "purple" {
//            cellDataGrid[section!][column!].addPurpleIndexToCellData(set)
//        } else {
//            print("NO CELL DATA SET HAS BEEN ADDED.")
//        }
//    }
//
//    
//}
//
//
//extension AlgorithmViewController: UICollectionViewDelegate, UICollectionViewDataSource{
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int{
//        return cellDataGrid.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if num_stations < 8 {
//            return 8
//        } else {
//            return cellDataGrid[section].count
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Selected cell at IndexPath: \(indexPath)")
//        if cellDataA == nil {
//            // First selection
////            indexPathA = indexPath
//            cellDataA = cellDataGrid[indexPath.section][indexPath.item]
//            changeCellGridData(cellDataInstance: cellDataA!, to: "selected")
//            let indexPathA = IndexPath(item: indexPath.item, section: indexPath.section )
//            if let selectedCellA = collectionView.cellForItem(at: indexPathA) as? AlgorithmCollectionViewCell {
//                selectedCellA.makeCellSelected()
//            }
//
//        } else if cellDataB == nil {
//            // Second selection
////            indexPathB = indexPath
//            cellDataB = cellDataGrid[indexPath.section][indexPath.item]
//            changeCellGridData(cellDataInstance: cellDataB!, to: "selected")
//            let indexPathB = IndexPath(item: indexPath.item, section: indexPath.section )
//            if let selectedCellB = collectionView.cellForItem(at: indexPathB) as? AlgorithmCollectionViewCell {
//                selectedCellB.makeCellSelected()
//            }
//        }
//        if let cellDataAIndex = cellDataA?.cellIndex, let cellDataBIndex = cellDataB?.cellIndex {
//            let indexPathA = IndexPath(item: cellDataAIndex.second, section: cellDataAIndex.first)
//            let indexPathB = IndexPath(item: cellDataBIndex.second, section: cellDataBIndex.first)
//
//            collectionView.performBatchUpdates({
//                collectionView.moveItem(at: indexPathA, to: indexPathB)
//                collectionView.moveItem(at: indexPathB, to: indexPathA)
//
//                }, completion: { _ in
////                    self.cellDataA?.changeCellIndex(section: (self.cellDataB?.cellIndex?.first)!, column: (self.cellDataB?.cellIndex?.second)!)
////                    self.cellDataB?.changeCellIndex(section: (self.cellDataA?.cellIndex?.first)!, column: (self.cellDataA?.cellIndex?.second)!)
//                    self.cellDataGrid[cellDataAIndex.first][cellDataAIndex.second] = self.cellDataB!
//                    self.cellDataGrid[cellDataBIndex.first][cellDataBIndex.second] = self.cellDataA!
//                    self.cellDataGrid[cellDataAIndex.first][cellDataAIndex.second].cellIndex = cellDataAIndex
//                    self.cellDataGrid[cellDataBIndex.first][cellDataBIndex.second].cellIndex = cellDataBIndex
//                    
//                    self.changeCellGridData(cellDataInstance: self.cellDataA!, to: "deselected")
//                    self.changeCellGridData(cellDataInstance: self.cellDataB!, to: "deselected")
//                    
//                    print("CELL SWAPPED: CELL NUMBER IN INDEX: ", self.cellDataGrid[0][3].cellIndex!, " with number: ", self.cellDataGrid[0][3].number!)
//                    print("CELL SWAPPED: CELL NUMBER IN INDEX: ", self.cellDataGrid[1][3].cellIndex!, " with number: ", self.cellDataGrid[1][3].number!)
////                self.grid[indexPathA.section][indexPathA.item] = self.cellDataB!.number!
////                self.grid[indexPathB.section][indexPathB.item] = self.cellDataA!.number!
//
//                    let selectedCellA = collectionView.cellForItem(at: indexPathA) as? AlgorithmCollectionViewCell
//                    let selectedCellB = collectionView.cellForItem(at: indexPathB) as? AlgorithmCollectionViewCell
//                    selectedCellA?.makeCellOriginal()
//                    selectedCellB?.makeCellOriginal()
//                    print("swap completed")
//                
//                    self.cellDataA = nil
//                    self.cellDataB = nil
//                
//                    self.resetAll()
//                    self.reloadAll()
//                    self.collectionView.reloadData()
//                
//
//            })
////            collectionView.reloadData()
//        }
//    }
//    
//
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlgorithmCollectionViewCell.identifier, for: indexPath) as? AlgorithmCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        
//        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//        doubleTapGestureRecognizer.numberOfTapsRequired = 2
//        cell.addGestureRecognizer(doubleTapGestureRecognizer)
//
//        
//        let cellData = cellDataGrid[indexPath.section][indexPath.item]
//        let teamNumberLabel = cellData.number
//        
//        if teamNumberLabel == -1 {
//            cell.makeCellInvisible()
//        } else if teamNumberLabel == 0 {
//            cell.makeCellEmpty()
//        }  else {
//            cell.configureAlgorithmNormalCell(cellteamnum : teamNumberLabel!)
//            
//            if cellData.hasPvpBlueWarning && !cellData.hasRedWarning {
//                cell.makeBlueWarning()
//            } else if (cellData.hasPvpYellowWarning || cellData.hasYellowWarning) && !cellData.hasRedWarning {
//                cell.makeYellowWarning()
//            } else if cellData.hasPurpleWarning && !cellData.hasRedWarning {
//                cell.makePurpleWarning()
//            } else if cellData.hasRedWarning {
//                cell.makeRedWarning()
//            }
//        }
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
////        let cellNumber = grid[indexPath.section][indexPath.item]
//        let cellNumber = cellDataGrid[indexPath.section][indexPath.item].number
//        
//        if shouldDisableInteraction(for: cellNumber!) {
//            return false
//        }
//        
//        return true
//    }
//
//    func shouldDisableInteraction(for cellNumber: Int) -> Bool {
//        return cellNumber == -1
//    }
//
//
//    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
//        guard let cell = sender.view as? AlgorithmCollectionViewCell else { return }
//        
//        if !cell.isSelected {
//            
//                let alertController = UIAlertController(title: "Enter the team number", message: nil, preferredStyle: .alert)
//                alertController.addTextField { textField in
//                textField.keyboardType = .numberPad
//            }
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
//                cell.isSelected = false
//                alertController.dismiss(animated: true, completion: nil)
//            }))
//        
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                if let numberString = alertController.textFields?.first?.text,
//                let number = Int(numberString) {
//                
//                    cell.teamnumLabel.text = "\(number)"
//                    if number == 0 {
//                        cell.makeCellEmpty()
//                    }
//                
//                    if let indexPath = self.collectionView.indexPath(for: cell) {
//                        let section = indexPath.section
//                        let item = indexPath.item
//                        self.cellDataGrid[section][item].changeCellData(number: number, visible: true)
//                        cell.number = number
//                    }
//                    self.resetAll()
//                    self.reloadAll()
//
//                    cell.isSelected = false
//                }
//            
//                alertController.dismiss(animated: true, completion: nil)
//            }))
//            present(alertController, animated: true, completion: nil)
//        }
//    }
//
//    func reloadAll() {
//        collectionView.isUserInteractionEnabled = false
//        if pvpGameCount > 0 {
//            processPvpYellowCells()
//            processPvpBlueCells()
//        }
////        updateCellBackgroundImages()
//        processPurpleSameRoundCells()
//        processYellowSameStationCells()
//        collectionView.reloadData()
//        DispatchQueue.main.async {
//            self.collectionView.isUserInteractionEnabled = true
//        }
//    }
//    
//    func resetAll() {
//        if let indexPaths = collectionView.indexPathsForSelectedItems, !indexPaths.isEmpty {
//            for indexPath in indexPaths {
//                self.collectionView.deselectItem(at: indexPath, animated: true)
//            }
//        }
//        for section in 0..<cellDataGrid.count {
//            for column in 0..<cellDataGrid[0].count {
//                if cellDataGrid[section][column].visible {
//                    cellDataGrid[section][column].resetCellToDefault()
//                    if let cell = collectionView.cellForItem(at: IndexPath(item: column, section: section)) as? AlgorithmCollectionViewCell {
//                        cell.makeCellOriginal()
//                    }
//                }
//            }
//        }
//    }
//}
//
//
//extension AlgorithmViewController: StationList {
//    func listOfStations(_ stations: [Station]) {
//        self.stationList = stations
//        self.num_stations = stations.count
//        self.collectionView?.reloadData()
//        var pvpCount = 0
//        for station in stations {
//            if station.pvp {
//                pvpCount += 1
//            }
//        }
//        self.pvpGameCount = pvpCount
//        self.pveGameCount = stations.count - pvpCount
//
//    }
//    
//}
//
//
//
//extension AlgorithmViewController: UICollectionViewDelegateFlowLayout {
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let width = (Int(collectionViewWidth - 20) - (16 * collectionViewCellSpacing)) / 8
//
//        collectionViewCellWidth = width > 0 ? Int(width) : Int(width - 1)
//        return CGSize(width: collectionViewCellWidth, height: collectionViewCellWidth)
//
//    }
//    
//
//
//}
//
//extension AlgorithmViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == collectionView {
//            print("------Collection view scrolling-----")
//        } else if scrollView == self.scrollView {
//            print("------Scroll view scrolling-------")
//        }
////        reloadAll()
//    }
//}
//
//extension  AlgorithmViewController : ModalViewControllerDelegate {
//    func modalViewControllerDidRequestPush() {
//        pushTabBarController()
//    }
//    
//    private func pushTabBarController() {
//        let storyboard = UIStoryboard(name: "Host", bundle: nil)
//        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "HostTabBarController") as? UITabBarController {
//            tabBarController.selectedIndex = 0
//            navigationController?.pushViewController(tabBarController, animated: true)
//        }
//    }
//}

