//
//  ManualAlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 4/2/23.
//

import UIKit

class ManualAlgorithmViewController: BaseViewController {
    
    private var scrollView: UIScrollView!
    private var collectionView: UICollectionView!
    
    @IBOutlet weak var stationsLabelImageView: UIImageView!
    @IBOutlet weak var roundsLabelImageView: UIImageView!
    
    private var gamecode = UserData.readGamecode("gamecode")!
    
    private var smallerGrid = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
    
    private var biggerGrid = [[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0]]
    
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
    
    private func fetchDataAndInitialize() {
        Task { [weak self] in
             do {
                 self?.stationList = try await S.getStationList2(self?.gamecode ?? "")
                 self?.num_stations = self?.stationList?.count ?? 0

                 // Count pvp and pve games
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
                 } catch {
                     print("Failed to fetch stationList")
                 }
            do {
                 // Fetch host data
                 if let host = try await H.getHost2(self?.gamecode ?? "") {
                     self?.host = host
                     self?.num_teams = host.teams
                     self?.num_rounds = host.rounds
                 } else {
                     print("Failed to fetch host")
                 }

                 // Call createGrid() here, once data is fetched
                 self?.createGrid()

                 // Reload the collection view once data is ready
                 DispatchQueue.main.async {
                     print(" num_stations, pvpGameCount, pveGamecount: ", self?.num_stations ?? 0, self?.pvpGameCount ?? 0, self?.pveGameCount ?? 0)
                     print("grid: ", self?.cellDataGrid.count ?? 0)
                     self?.collectionView?.reloadData()
                 }
             } catch(let e) {
                 print(e)
                 return
             }
         }
    }
        
    
    private func createGrid() {
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
//                        changeCellGridData(cellDataInstance: cellData, to: "empty")
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

        scrollView.backgroundColor = UIColor.yellow
        collectionView.backgroundColor = UIColor.tintColor

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(AlgorithmCollectionViewCell.self, forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")

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
        if section < cellDataGrid.count {
            return cellDataGrid[section].count
        }
        return 0

    }
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return cellDataGrid.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "AlgorithmCollectionViewCell", for: indexPath) as? AlgorithmCollectionViewCell else {
            return UICollectionViewCell()
        }
       
        if indexPath.section % 2 == 0 {
            cell.configureTestCell1()
        } else {
            cell.configureTestCell2()
        }

        return cell
    }
    
    
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
