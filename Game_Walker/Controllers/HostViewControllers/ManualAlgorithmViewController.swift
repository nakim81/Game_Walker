//
//  ManualAlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 4/2/23.


import UIKit

class ManualAlgorithmViewController: BaseViewController {
    
    private var scrollView: UIScrollView!
    private var collectionView: UICollectionView!
    
    @IBOutlet weak var stationsLabelImageView: UIImageView!
    @IBOutlet weak var roundsLabelImageView: UIImageView!
    
    private var gamecode = UserData.readGamecode("gamecode")!
    
    private var collectionViewWidth = UIScreen.main.bounds.width * 0.75
    private var collectionViewCellSize : CGSize?
    private var collectionViewCellWidth : CGFloat?
    private var collectionViewCellSpacing: CGFloat = 6.0

    // variables for data
    private var cellDataGrid : [[CellData]] = [[CellData]]()
    
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
    private var pvpGameCount : Int = 0
    private var pveGameCount : Int = 0
    private var omittedTeamCells = 0
    
    private var stationList: [Station]? = nil
    private var host : Host?
    
    var cellDataA : CellData?
    var cellDataB : CellData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionViewScrollView()
        fetchDataAndInitialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calculateSizesAndContentSize()
        setUpLabels()
    }
    
    //method to ensure data
    private func dataDidLoad() {

        createGrid()
        
        //reload!
        DispatchQueue.main.async {
//            print(" num_stations, pvpGameCount, pveGamecount: ", self.num_stations , self.pvpGameCount , self.pveGameCount )
//            print("grid: ", self.cellDataGrid.count)
            self.collectionView?.reloadData()
        }
    }
    
    private func fetchDataAndInitialize() {
        Task { [weak self] in
            do {
                self?.stationList = try await S.getStationList2(self?.gamecode ?? "")
                self?.num_stations = self?.stationList?.count ?? 0
                var pvpCount = 0
                if let unwrappedStationList = self?.stationList {
                    for station in unwrappedStationList {
                        if station.pvp {
                            pvpCount += 1
                        }
                    }
                }

                self?.pvpGameCount = pvpCount
                self?.pveGameCount = self?.num_stations ?? 0 - pvpCount
                
                self?.host = try await H.getHost2(self?.gamecode ?? "")
                self?.num_teams = self?.host?.teams ?? 0
                self?.num_rounds = self?.host?.rounds ?? 0

                self?.createGrid()

                // Reload the collection view once data is ready (on the main thread)
                DispatchQueue.main.async { [weak self] in

                    self!.collectionView.dataSource = self
                    self!.collectionView.delegate = self
                    self?.collectionView?.reloadData()
                }
            } catch {
                print("Error in fetchDataAndInitialize: \(error)")
            }
        }
    }

        
    
    private func createGrid() {
        print("somehow inside create grid")
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
    
            // adding grid with celldata
            var currCellDataRow: [CellData] = []
    
            for t in 0..<totalcolumn {
                var number = (t + (r + 1)) % totalcolumn
                if number == 0 {
                    number = totalcolumn
                }
    
    
            var visible = true
            if excessOf == "stations" || excessOf == "teams" {
            if t >= totalcolumn - excessCells {
                if excessOf == "stations" {
                        number = 0
                    } else if excessOf == "teams" {
                        number = -1
                        visible = false
                    }
                }
            }
            let celldata = CellData(number: number, visible: visible, index: IntPair(first: r, second: t))
            currRow.append(number)
            currCellDataRow.append(celldata)
        }
            
            while currRow.count < 8 {
                currRow.append(-1)
                let celldata = CellData(number: -1, visible: false, index: IntPair(first:r, second:currRow.count))
                currCellDataRow.append(celldata)
            }
            cellDataGrid.append(currCellDataRow)
        }
    
    
        for rowIndex in stride(from: 1, through: cellDataGrid.count - 1, by: 2) {
            for column in 0..<(pvpGameCount * 2) {
                let cellData = cellDataGrid[rowIndex][column]
                if cellData.number != -1 {
//                       changeCellGridData(cellDataInstance: cellData, to: "empty")
                    print("have to change cell to empty")
                }
            }
        }
        var count = 0
        for row in cellDataGrid {
            count += 1
            var rownums = [Int]()
            for celldata in row {
                rownums.append(celldata.number!)
            }
            print("celldatagrid at row ", count, " is ", rownums)
        }
    }
        
    //helper functions
    
    
    private func numberIsValid(_ number: Int?) -> Bool {
        if number != nil && number != 0 && number != -1 {
            return true
        } else {
            return false
        }
    }
    
    private func hasOmittedTeamCells() -> Int {
        let stationCells = pvpGameCount * 2 + pveGameCount
        let teamCells = num_teams

        if teamCells > stationCells {
            print("Be cautious there are omitted Team Cells.")
            return teamCells - stationCells
        }
        return 0
    }
    
    private func changeCellGridData(cellDataInstance: CellData, to state: String) {
        let section = cellDataInstance.cellIndex?.first
        let column = cellDataInstance.cellIndex?.second
        cellDataGrid[section!][column!].changeState(to: state)
    }
    
    private func addCellSetsToCellGridData(cellDataInstance: CellData, to color: String, set: Set<CellData>) {
        let section = cellDataInstance.cellIndex?.first
        let column = cellDataInstance.cellIndex?.second
        if color == "blue" {
            cellDataGrid[section!][column!].addBluePvpIndexToCellData(set)
        } else if color == "yellowPvp" {
            cellDataGrid[section!][column!].addYellowPvpIndexToCellData(set)
        } else if color == "yellow" {
            cellDataGrid[section!][column!].addYellowIndexToCellData(set)
        } else if color == "purple" {
            cellDataGrid[section!][column!].addPurpleIndexToCellData(set)
        } else {
            print("NO CELL DATA SET HAS BEEN ADDED.")
        }
    }
    
    private func calculateSizesAndContentSize() {
        var numberOfItemsInARow = 8
        let cellSpacing = collectionViewCellSpacing

        if collectionView.numberOfItems(inSection: 0) > 8 {
            numberOfItemsInARow = collectionView.numberOfItems(inSection: 0)
        }
        let contentWidth = CGFloat(numberOfItemsInARow) * (collectionViewCellSize!.width + cellSpacing) + cellSpacing
        
        scrollView.contentSize = CGSize(width: contentWidth, height: collectionView.contentSize.height)
        collectionView.contentSize = scrollView.contentSize
        let collectionViewWidthConstraint = collectionView.widthAnchor.constraint(equalToConstant:  scrollView.contentSize.width)
        collectionViewWidthConstraint.isActive = true
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = collectionViewCellSize!
            flowLayout.minimumInteritemSpacing = collectionViewCellSpacing
            flowLayout.minimumLineSpacing = collectionViewCellSpacing
        }
    }
    
    private  func getCellCurrPlayingWith(_ cellData: CellData) -> CellData {
        if cellData.cellIndex!.second % 2 == 0 {
            return cellDataGrid[cellData.cellIndex!.first][cellData.cellIndex!.second + 1]
        } else {
            return cellDataGrid[cellData.cellIndex!.first][cellData.cellIndex!.second - 1]
        }
    }
    
    func reloadAll() {
        collectionView.isUserInteractionEnabled = false
        if pvpGameCount > 0 {
            processPvpYellowCells()
            processPvpBlueCells()
        }
        processPurpleSameRoundCells()
        processYellowSameStationCells()
        collectionView.reloadData()
        DispatchQueue.main.async {
            self.collectionView.isUserInteractionEnabled = true
        }
    }
    
    func resetAll() {
        if let indexPaths = collectionView.indexPathsForSelectedItems, !indexPaths.isEmpty {
            for indexPath in indexPaths {
                self.collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
        for section in 0..<cellDataGrid.count {
            for column in 0..<cellDataGrid[0].count {
                if cellDataGrid[section][column].visible {
                    cellDataGrid[section][column].resetCellToDefault()
                    if let cell = collectionView.cellForItem(at: IndexPath(item: column, section: section)) as? AlgCollectionViewCell {
                        cell.makeCellOriginal()
                        cell.backgroundColor = UIColor.systemPink
                    }
                }
            }
        }
    }
    //helperfunctions end
    
    
    
//    processing functions
    
    private func processPvpBlueCells() {
        var numbersSeenByNumber = [Int: Set<Int>]()
        var duplicatedPairs = Set<IntPair>()
        for pairIndex in 0...(pvpGameCount - 1) {
            let startColumn = pairIndex * 2
            let endColumn = startColumn + 1
                for section in 0..<cellDataGrid.count {
                    let cellData1 = cellDataGrid[section][startColumn]
                    let cellData2 = cellDataGrid[section][endColumn]
                    let numberKey1 = cellData1.number
                    let numberKey2 = cellData2.number
    
                    if numberIsValid(numberKey1) {
                        if var seenNumbers = numbersSeenByNumber[numberKey1!] {
                            if numberIsValid(numberKey2) {
                                if seenNumbers.contains(numberKey2!) {
                                    duplicatedPairs.insert(IntPair(first: numberKey1!, second: numberKey2!))
                                } else {
                                    seenNumbers.insert(numberKey2!)
                                    numbersSeenByNumber[numberKey1!] = seenNumbers
                                    if var seenNumbersPair = numbersSeenByNumber[numberKey2!]{
                                        if numberIsValid(numberKey1) {
                                            if !seenNumbersPair.contains(numberKey1!) {
                                                seenNumbersPair.insert(numberKey1!)
                                                numbersSeenByNumber[numberKey2!] = seenNumbersPair
                                            }
                                        }
                                    } else {
                                        var newNumberSet = Set<Int>()
                                        newNumberSet.insert(numberKey1!)
                                        numbersSeenByNumber[numberKey2!] = newNumberSet
                                    }
                                }
                            }
                        } else {
                            if numberIsValid(numberKey2) {
                                var newNumberSet1 = Set<Int>()
                                var newNumberSet2 = Set<Int>()
                                newNumberSet1.insert(numberKey2!)
                                numbersSeenByNumber[numberKey1!] = newNumberSet1
                                newNumberSet2.insert(numberKey1!)
                                numbersSeenByNumber[numberKey2!] = newNumberSet2
                            }
                        }
                    }
            }
        }
        makeAllDuplicatePairsBlue(duplicatedPairs)
    }
    
    private func makeAllDuplicatePairsBlue(_ duplicatedPairs : Set<IntPair>) {
        var allCellsWithDuplicatedMatchesByPairs = [IntPair: Set<CellData>]()
    
        for pairIndex in 0...(pvpGameCount-1) {
            let evenColumn = pairIndex * 2
            for section in 0..<cellDataGrid.count {
    
                let cellData1 = cellDataGrid[section][evenColumn]
                let cellData2 = getCellCurrPlayingWith(cellData1)
                let number1 = cellData1.number
                let number2 = cellData2.number
    
                // indexPathsByPairs with have the same IntPair value for either switched or not switched pairs.
                // example: IntPair(1,2) and IntPair(2,1) will have the Key of IntPair(1,2)
                let currPair = IntPair(first: number1!, second: number2!)
                let currPairSwitched = currPair.switchPair(currPair)
                let currPairKey = currPair.cleanOrderPair(currPair)

                if duplicatedPairs.contains(currPair) || duplicatedPairs.contains(currPairSwitched) {
                    if var cellDataSet = allCellsWithDuplicatedMatchesByPairs[currPairKey] {
                        cellDataSet.insert(cellData1)
                        cellDataSet.insert(cellData2)
                        allCellsWithDuplicatedMatchesByPairs[currPairKey] = cellDataSet
                    } else {
                        var newCellDataSet = Set<CellData>()
                        newCellDataSet.insert(cellData1)
                        newCellDataSet.insert(cellData2)
                        allCellsWithDuplicatedMatchesByPairs[currPairKey] = newCellDataSet
                    }
                }
            }
        }
    
        for (_, cellDataSet) in allCellsWithDuplicatedMatchesByPairs {
            for cellData in cellDataSet {
                addCellSetsToCellGridData(cellDataInstance: cellData, to: "blue", set: cellDataSet)
    
                //Case where cells that need blue warnings already has yellow pvp warnings
                if cellData.hasPvpYellowWarning {
                    changeCellGridData(cellDataInstance: cellData, to: "red")
                    for yellowCellData in cellData.cellsWithSameYellowPvpWarning {
                        changeCellGridData(cellDataInstance: yellowCellData, to: "red")
                    }
                    for currCellData in cellData.cellsWithSameBluePvpWarning {
                        changeCellGridData(cellDataInstance: currCellData, to: "red")
                    }
                } else if cellData.hasPurpleWarning {
                    for purpleCellData in cellData.cellsWithSamePurpleWarning {
                        changeCellGridData(cellDataInstance: purpleCellData, to: "red")
                    }
                    for currCellData in cellData.cellsWithSameBluePvpWarning {
                        changeCellGridData(cellDataInstance: currCellData, to: "red")
                    }
                } else if cellData.hasYellowWarning{
                    for yellowCellData in cellData.cellsWithSameYellowWarning {
                        changeCellGridData(cellDataInstance: yellowCellData, to: "red")
                    }
                    for currCellData in cellData.cellsWithSameBluePvpWarning {
                        changeCellGridData(cellDataInstance: currCellData, to: "red")
                    }
                } else if cellData.hasRedWarning {
                    for currCellData in cellData.cellsWithSameBluePvpWarning {
                        changeCellGridData(cellDataInstance: currCellData, to: "red")
                    }
                }else {
                    changeCellGridData(cellDataInstance: cellData, to: "blue")
                    print("changing a pvp blue cell to blue. no other error encountered")
                }
            }
        }
    }
    
    private func processPvpYellowCells () {
        for pairIndex in 0..<pvpGameCount {
            let startColumn = pairIndex * 2
            let endColumn = startColumn + 1

            var matchedCellsByNumber = [Int: Set<CellData>]()
    
            for section in 0..<cellDataGrid.count {
                for column in startColumn...endColumn {
                    let cellData = cellDataGrid[section][column]
                    let numberKey = cellData.number
    
                    if numberIsValid(numberKey) {
                        //Checking if IntPairsByNumbers already has the numberkey
                        if var cellDataSet = matchedCellsByNumber[numberKey!] {
                            cellDataSet.insert(cellData)
                            matchedCellsByNumber[numberKey!] = cellDataSet
                        } else {
                            var newCellDataSet = Set<CellData>()
                            newCellDataSet.insert(cellData)
                            matchedCellsByNumber[numberKey!] = newCellDataSet
                        }
                    }
                }
            }
            // Check number keys with multiple cells.
            // This will tell if there are duplicates in the two pvp column pairs.
            for (_, cellDataset) in matchedCellsByNumber {
                if cellDataset.count >= 2 {
                    for cellData in cellDataset {
                        changeCellGridData(cellDataInstance: cellData, to: "yellowPvp")
                        addCellSetsToCellGridData(cellDataInstance: cellData, to: "yellowPvp", set: cellDataset)
                    }
                }
            }
        }
    }
    
    private func processPurpleSameRoundCells() {
        for row in cellDataGrid {
            var rowNumbers = [Int: Set<CellData>]()
            for cellData in row {
                let number = cellData.number

                if numberIsValid(number) {
                    if var cellDataSet = rowNumbers[number!] {
                        cellDataSet.insert(cellData)
                        rowNumbers[number!] = cellDataSet
                    } else {
                        var newCellDataSet = Set<CellData>()
                        newCellDataSet.insert(cellData)
                        rowNumbers[number!] = newCellDataSet
                    }
                }
            }
                //Now mark each cell with more than two counts in sets in each row
            for (_, cellDataSet) in rowNumbers {
                if cellDataSet.count >= 2 {
                    for cellDataDuplicates in cellDataSet {
                        addCellSetsToCellGridData(cellDataInstance: cellDataDuplicates, to: "purple", set: cellDataSet)
    
                        if cellDataDuplicates.hasRedWarning {
                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "red")
                        } else if cellDataDuplicates.hasPvpBlueWarning {
                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "red")
                            for pvpBlueCellData in cellDataDuplicates.cellsWithSameBluePvpWarning {
                                changeCellGridData(cellDataInstance: pvpBlueCellData, to: "red")
                            }
                            for currCellData in cellDataDuplicates.cellsWithSamePurpleWarning   {
                                changeCellGridData(cellDataInstance: currCellData, to: "red")
                            }
                        } else if cellDataDuplicates.hasPvpYellowWarning {
                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "red")
                            for pvpYellowCellData in cellDataDuplicates.cellsWithSameYellowPvpWarning {
                                changeCellGridData(cellDataInstance: pvpYellowCellData, to: "red")
                            }
                            for currCellData in cellDataDuplicates.cellsWithSamePurpleWarning   {
                                changeCellGridData(cellDataInstance: currCellData, to: "red")
                            }
                        } else {
                            changeCellGridData(cellDataInstance: cellDataDuplicates, to: "purple")
                        }
                    }
                }
            }
        }
        }
    
    func processYellowSameStationCells() {
        print("PROCESS YELLOW SAME STATION CELLS")
        for col in 0..<cellDataGrid[0].count {
            var columnNumbers = [Int: Set<CellData>]()
            for sect in 0..<cellDataGrid.count {
                let cellData = cellDataGrid[sect][col]
                let number = cellData.number
    
                if numberIsValid(number) {
                    if var cellDataSet = columnNumbers[number!] {
                        cellDataSet.insert(cellData)
                        columnNumbers[number!] = cellDataSet
                    } else {
                        var newCellDataSet = Set<CellData>()
                        newCellDataSet.insert(cellData)
                        columnNumbers[number!] = newCellDataSet
                    }
                }
            }
            for (_, cellDataSet) in columnNumbers {
                if cellDataSet.count >= 2 {
                    for cellDataWithWarning in cellDataSet {
                        addCellSetsToCellGridData(cellDataInstance: cellDataWithWarning, to: "yellow", set: cellDataSet)
                        if cellDataWithWarning.hasPurpleWarning {
                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
                            for purpleCellData in cellDataWithWarning.cellsWithSamePurpleWarning {
                                changeCellGridData(cellDataInstance: purpleCellData, to: "red")
                            }
                            for currCellData in cellDataWithWarning.cellsWithSameYellowWarning   {
                                changeCellGridData(cellDataInstance: currCellData, to: "red")
                            }
                        } else if cellDataWithWarning.hasRedWarning {
                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")

                        } else if cellDataWithWarning.hasPvpBlueWarning {
                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
                            for pvpBlueCellData in cellDataWithWarning.cellsWithSameBluePvpWarning {
                                changeCellGridData(cellDataInstance: pvpBlueCellData, to: "red")
                            }
                            for currCellData in cellDataWithWarning.cellsWithSameYellowWarning   {
                                changeCellGridData(cellDataInstance: currCellData, to: "red")
                            }
                        } else if cellDataWithWarning.hasPvpYellowWarning {
    //                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "red")
    //                            for pvpYellowCellData in cellDataWithWarning.cellsWithSameYellowPvpWarning {
    //                                changeCellGridData(cellDataInstance: pvpYellowCellData, to: "red")
    //                            }
                        } else {
                            changeCellGridData(cellDataInstance: cellDataWithWarning, to: "yellow")
                        }
                    }
                }
            }
        }
    }
    
    
    
    //setting collectionview and scrollview apart from data
    
    private func setUpCollectionViewScrollView() {

        let totalSpacing = collectionViewCellSpacing * 9
        let availableWidth = floor(collectionViewWidth - totalSpacing)
        let toTheRight = collectionViewWidth * 0.05
        collectionViewCellWidth = availableWidth / 8
        collectionViewCellSize = CGSize(width: collectionViewCellWidth!, height: collectionViewCellWidth!)

        collectionViewCellSize = CGSize(width: collectionViewCellWidth!,
                                        height: collectionViewCellWidth!)

        //create
        
        scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)



        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:  UICollectionViewFlowLayout())
        collectionView.delaysContentTouches = true
        collectionView.isScrollEnabled = true


        collectionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(collectionView)

//        scrollView.backgroundColor = UIColor.yellow
//        collectionView.backgroundColor = UIColor.tintColor


//        collectionView.register(AlgCollectionViewCell.self, forCellWithReuseIdentifier: AlgCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: "AlgCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgCollectionViewCell")


        let centerYMultiplier: CGFloat = 0.96
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: toTheRight) ,
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:  -view.frame.size.height * (1 - centerYMultiplier)),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            scrollView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75), // Make it square
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setUpLabels() {
        stationsLabelImageView.translatesAutoresizingMaskIntoConstraints = false
        roundsLabelImageView.translatesAutoresizingMaskIntoConstraints = false

        let stationsLabelWidthMultiplier: CGFloat = 116.0 / 281.0
        let roundsLabelHeightMultiplier: CGFloat = 104.0 / 291.0
    
        
        NSLayoutConstraint.activate([
            // Constraints for stationsLabelImageView
            stationsLabelImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: stationsLabelWidthMultiplier),
            stationsLabelImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stationsLabelImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -5 - stationsLabelImageView.frame.height),

            // Constraints for roundsLabelImageView
            roundsLabelImageView.heightAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: roundsLabelHeightMultiplier),
            roundsLabelImageView.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: -5), // 5 points to the left of collectionView
            roundsLabelImageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])


    }
       
}



extension ManualAlgorithmViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !self.stationList!.isEmpty && self.host != nil{
            if num_stations < 8 {
                return 8
            } else {
                return cellDataGrid[section].count
            }
        } else {
            return 0
        }

    }
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        if !self.stationList!.isEmpty && self.host != nil {
            return cellDataGrid.count
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected cell at IndexPath: \(indexPath)")
        if cellDataA == nil {
            // First selection
    //           indexPathA = indexPath
            cellDataA = cellDataGrid[indexPath.section][indexPath.item]
            changeCellGridData(cellDataInstance: cellDataA!, to: "selected")
            let indexPathA = IndexPath(item: indexPath.item, section: indexPath.section )
            if let selectedCellA = collectionView.cellForItem(at: indexPathA) as? AlgCollectionViewCell {
                selectedCellA.makeCellSelected()
            }

        } else if cellDataB == nil {
            // Second selection
            cellDataB = cellDataGrid[indexPath.section][indexPath.item]
            changeCellGridData(cellDataInstance: cellDataB!, to: "selected")
            let indexPathB = IndexPath(item: indexPath.item, section: indexPath.section )
            if let selectedCellB = collectionView.cellForItem(at: indexPathB) as? AlgCollectionViewCell {
                selectedCellB.makeCellSelected()
            }
        }
        if let cellDataAIndex = cellDataA?.cellIndex, let cellDataBIndex = cellDataB?.cellIndex {
            let indexPathA = IndexPath(item: cellDataAIndex.second, section: cellDataAIndex.first)
            let indexPathB = IndexPath(item: cellDataBIndex.second, section: cellDataBIndex.first)
    
            collectionView.performBatchUpdates({
                collectionView.moveItem(at: indexPathA, to: indexPathB)
                collectionView.moveItem(at: indexPathB, to: indexPathA)
    
                }, completion: { _ in

                    self.cellDataGrid[cellDataAIndex.first][cellDataAIndex.second] = self.cellDataB!
                    self.cellDataGrid[cellDataBIndex.first][cellDataBIndex.second] = self.cellDataA!
                    self.cellDataGrid[cellDataAIndex.first][cellDataAIndex.second].cellIndex = cellDataAIndex
                    self.cellDataGrid[cellDataBIndex.first][cellDataBIndex.second].cellIndex = cellDataBIndex
    
                    self.changeCellGridData(cellDataInstance: self.cellDataA!, to: "deselected")
                    self.changeCellGridData(cellDataInstance: self.cellDataB!, to: "deselected")
    
                    print("CELL SWAPPED: CELL NUMBER IN INDEX: ", self.cellDataGrid[0][3].cellIndex!, " with number: ", self.cellDataGrid[0][3].number!)
                    print("CELL SWAPPED: CELL NUMBER IN INDEX: ", self.cellDataGrid[1][3].cellIndex!, " with number: ", self.cellDataGrid[1][3].number!)

                    let selectedCellA = collectionView.cellForItem(at: indexPathA) as? AlgCollectionViewCell
                    let selectedCellB = collectionView.cellForItem(at: indexPathB) as? AlgCollectionViewCell
                    selectedCellA?.makeCellOriginal()
                    selectedCellB?.makeCellOriginal()
                    print("swap completed")
    
                    self.cellDataA = nil
                    self.cellDataB = nil
    
                    self.resetAll()
                    self.reloadAll()
                    self.collectionView.reloadData()
            })
        }
    }
    
    
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlgCollectionViewCell.identifier, for: indexPath) as? AlgCollectionViewCell else {
                return UICollectionViewCell()
            }
    
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            cell.addGestureRecognizer(doubleTapGestureRecognizer)
    
    
            let cellData = cellDataGrid[indexPath.section][indexPath.item]
            let teamNumberLabel = cellData.number
    
            if teamNumberLabel == -1 {
                cell.makeCellInvisible()
            } else if teamNumberLabel == 0 {
                cell.makeCellEmpty()
            }  else {
                cell.configureAlgorithmNormalCell(cellteamnum : teamNumberLabel!)
    
                if cellData.hasPvpBlueWarning && !cellData.hasRedWarning {
                    cell.makeBlueWarning()
                } else if (cellData.hasPvpYellowWarning || cellData.hasYellowWarning) && !cellData.hasRedWarning {
                    cell.makeYellowWarning()
                } else if cellData.hasPurpleWarning && !cellData.hasRedWarning {
                    cell.makePurpleWarning()
                } else if cellData.hasRedWarning {
                    cell.makeRedWarning()
                }
            }
            return cell
        }
    
        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    //        let cellNumber = grid[indexPath.section][indexPath.item]
            let cellNumber = cellDataGrid[indexPath.section][indexPath.item].number
    
            if shouldDisableInteraction(for: cellNumber!) {
                return false
            }
    
            return true
        }
    
        func shouldDisableInteraction(for cellNumber: Int) -> Bool {
            return cellNumber == -1
        }
    
    
        @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            guard let cell = sender.view as? AlgCollectionViewCell else { return }
    
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
    
                        cell.numberLabel.text = "\(number)"
                        if number == 0 {
                            cell.makeCellEmpty()
                        }
    
                        if let indexPath = self.collectionView.indexPath(for: cell) {
                            let section = indexPath.section
                            let item = indexPath.item
                            self.cellDataGrid[section][item].changeCellData(number: number, visible: true)
                            cell.number = number
                        }
                        self.resetAll()
                        self.reloadAll()
    
                        cell.isSelected = false
                    }
    
                    alertController.dismiss(animated: true, completion: nil)
                }))
                present(alertController, animated: true, completion: nil)
            }
        }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "AlgCollectionViewCell", for: indexPath) as? AlgCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//
//        if indexPath.section % 2 == 0 {
//            cell.configureTestCell1()
//        } else {
//            cell.configureTestCell2()
//        }
//
//        return cell
//    }
    
    
}

extension ManualAlgorithmViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == collectionView.numberOfSections - 1 {
            return UIEdgeInsets(top: 0, left:collectionViewCellSpacing, bottom: 0, right: collectionViewCellSpacing)
        } else if section == 0{
            return UIEdgeInsets(top: collectionViewCellSpacing, left:collectionViewCellSpacing, bottom: collectionViewCellSpacing, right: collectionViewCellSpacing)
        }else {
            return UIEdgeInsets(top: 0, left:collectionViewCellSpacing, bottom: collectionViewCellSpacing, right: collectionViewCellSpacing)
        }
    }
}
