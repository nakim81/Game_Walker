//
//  PlayerFrame3_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/16/22.
//

import Foundation
import UIKit

class CreateTeamViewController: UIViewController {
    
    @IBOutlet weak var teamNameLbl: UILabel!
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var teamNumberLbl: UILabel!
    @IBOutlet weak var teamNumberTextField: UITextField!
    @IBOutlet weak var chooseLbl: UILabel!
    @IBOutlet weak var createTeamButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var currentPlayer = UserData.readPlayer("player") ?? Player()
    private var gameCode = UserData.readGamecode("gamecode") ?? ""
    private var host: Host?
    
    private let audioPlayerManager = AudioPlayerManager()

    private let iconImageNames : [String] = [
        "iconBoy", "iconBear", "iconJam-min 1", "iconGeum-Jjok", "iconGirl", "iconBunny", "iconPenguin", "iconDuck", "iconSheep", "iconMonkey", "iconCat", "iconPig", "iconPanda", "iconWholeApple", "iconCutApple", "iconCherry", "iconDaisy", "iconpeas", "iconPea 1", "iconPlant", "iconAir",
        "iconDust", "iconFire", "iconWater", "iconRed", "iconOrange", "iconYellow", "iconGreen", "iconBlue",
        "iconNavyblue", "iconPurple", "iconPink",
    ]
    
    private var selectedIconName : String? {
        get {
            if let selectedIndex = selectedIndex {
                return iconImageNames[selectedIndex]
            } else {
                return nil
            }
        }
    }
    
    private var selectedIndex : Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSimpleNavBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetUp()
        configureCollectionView()
    }

    private func viewSetUp(){
        teamNameTextField.delegate = self
        teamNumberTextField.delegate = self
        
        teamNameTextField.layer.cornerRadius = 10
        teamNameTextField.layer.borderWidth = 3
        teamNameTextField.layer.borderColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 1).cgColor
        teamNumberTextField.layer.cornerRadius = 10
        teamNumberTextField.layer.borderWidth = 3
        teamNumberTextField.layer.borderColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 1).cgColor
        teamNumberTextField.keyboardType = .asciiCapableNumberPad
        teamNameLbl.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 30))
        teamNumberLbl.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 30))
        chooseLbl.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 30))
        
        createTeamButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        createTeamButton.layer.cornerRadius = 8
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.register(TeamIconCollectionViewCell.self, forCellWithReuseIdentifier: TeamIconCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.clipsToBounds = true
    }
    
    @IBAction func createTeamButtonPressed(_ sender: UIButton) {
        
        let groundView = UIView()
        groundView.center = view.center
        groundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        groundView.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(groundView)
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        spinner.style = .large
        spinner.color = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        groundView.addSubview(spinner)
        spinner.startAnimating()
        
        let loadingLabel = UILabel()
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        loadingLabel.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 19))
        loadingLabel.textAlignment = .center
        loadingLabel.frame = CGRect(x: spinner.frame.origin.x + ((loadingLabel.frame.size.width - spinner.frame.size.width) / 2), y: spinner.frame.origin.y + spinner.frame.size.height + 10, width: spinner.frame.size.width * 2, height: 20)
        groundView.addSubview(loadingLabel)
        
        func removeLoadingIndicator() {
            DispatchQueue.main.async {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                loadingLabel.removeFromSuperview()
                groundView.removeFromSuperview()
            }
        }
        
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")

        guard let teamName = teamNameTextField.text, !teamName.isEmpty else {
            removeLoadingIndicator()
            alert(title: NSLocalizedString("Team Name Error", comment: ""), message: NSLocalizedString("Team name should exist! Fill out the team name box.", comment: ""))
            return
        }
        guard let teamNumber = teamNumberTextField.text, !teamNumber.isEmpty else {
            removeLoadingIndicator()
            alert(title: NSLocalizedString("Team Number Error", comment: ""), message: NSLocalizedString("Team number should exist! Fill out the team number box.", comment: ""))
            return
        }
        
        Task { @MainActor in
            do {
                async let host = H.getHost(gameCode)
                async let stationListTask = S.getStationList(gameCode)
                self.host = try await host
                let stationList = try await stationListTask

                guard let standardStyle = self.host?.standardStyle else {
                    removeLoadingIndicator()
                    return
                }
                
                guard let selectedIconName = selectedIconName else {
                    removeLoadingIndicator()
                    alert(title: NSLocalizedString("No Icon Selected", comment: ""), message: NSLocalizedString("Please select a team icon.", comment: ""))
                    return
                }
                
                guard let tn = Int(teamNumber) else {
                    removeLoadingIndicator()
                    return
                }
                
                guard let hn = self.host?.teams else {
                    removeLoadingIndicator()
                    return
                }
                
                if tn > 0 {
                    if standardStyle {
                        guard let temp = self.host?.algorithm, !temp.isEmpty else {
                            removeLoadingIndicator()
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("The game is not created yet.\nPlease try again a few minutes later.", comment: ""))
                            return
                        }
                        let algorithm = convert1DArrayTo2D(temp)
                        if (!algorithm.isEmpty) {
                            teamNameTextField.resignFirstResponder()
                            
                            if (tn > hn) {
                                removeLoadingIndicator()
                                alert(title: NSLocalizedString("Invalid Team Number", comment: ""), message: NSLocalizedString("Please try other team numbers.", comment: ""))
                                return
                            }
                            
                            ///find the order of stations for player's team
                            let stationOrder = self.getStationOrder(algorithm , tn , stationList)
                            let newTeam = Team(gamecode: gameCode, name: teamName, number: tn , players: [currentPlayer], points: 0, stationOrder: stationOrder, iconName: selectedIconName)
                            UserData.writeTeam(newTeam, "team")
                            UserData.setStandardStyle(standardStyle)
                            Task { @MainActor in
                                do {
                                    try await T.addTeam(gameCode, newTeam)
                                    removeLoadingIndicator()
                                    performSegue(withIdentifier: "goToTPF4", sender: self)
                                } catch GameWalkerError.teamNumberAlreadyExists(let e) {
                                    print(e)
                                    removeLoadingIndicator()
                                    teamNumberAlert(e)
                                    return
                                } catch GameWalkerError.serverError(let text){
                                    print(text)
                                    removeLoadingIndicator()
                                    serverAlert(text)
                                    return
                                }
                            }
                        } else {
                            removeLoadingIndicator()
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("The game is not created yet.\nPlease try again a few minutes later.", comment: ""))
                            return
                        }
                    } else {
                        let newTeam = Team(gamecode: gameCode, name: teamName, number: tn , players: [currentPlayer], points: 0, stationOrder: [], iconName: selectedIconName)
                        UserData.writeTeam(newTeam, "team")
                        UserData.setStandardStyle(standardStyle)
                        Task { @MainActor in
                            do {
                                try await T.addTeam(gameCode, newTeam)
                                removeLoadingIndicator()
                                performSegue(withIdentifier: "goToTPF4", sender: self)
                            } catch GameWalkerError.teamNumberAlreadyExists(let e) {
                                removeLoadingIndicator()
                                print(e)
                                teamNumberAlert(e)
                                return
                            } catch GameWalkerError.serverError(let text){
                                removeLoadingIndicator()
                                print(text)
                                serverAlert(text)
                                return
                            }
                        }
                    }
                } else {
                    removeLoadingIndicator()
                    alert(title: NSLocalizedString("Team Number Error", comment: ""), message: NSLocalizedString("Team number should be greater than 0.", comment: ""))
                    return
                }
            } catch(let e) {
                removeLoadingIndicator()
                print(e)
                alert(title: NSLocalizedString("Connection Error", comment: ""), message: e.localizedDescription)
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarController = segue.destination as? PlayerTabBarController {
            // Determine the value of "standardStyle" (true or false)
            guard let isStandardStyle = self.host?.standardStyle else {return}
            
            // Pass the "standardStyle" value to the tab bar controller
            tabBarController.standardStyle = isStandardStyle
        }
    }
}
// MARK: - Methods for checking if the game started
extension CreateTeamViewController {
    
    ///return the order of staions for the team
    private func getStationOrder(_ algorithm: [[Int]], _ teamNumber: Int, _ stationList: [Station]) -> [Int] {
        var index = 0 ///represents the column index in the row
        var order: [Int] = []
        ///each row of the algorithm = teams
        for teams in algorithm {
            ///each column of the algorithm = team
            for team in teams {
                /// if my team found in the row
                if team == teamNumber {
                    order.append(index)
                    break
                } else {
                    index += 1
                }
                ///if my team not found in the row
                if index >= teams.count {
                    order.append(-1)
                }
            }
            ///reset search index when moving to the next row
            index = 0
        }
        
        let pvp = findNumberOfPVP(stationList) ///number of pvp games
        var actualOrder: [Int] = [] //array of station.numbers
        
        /// if no pvp game, then order = actualOrder
        if pvp == 0 {
            for column in order {
                if column == -1 {
                    actualOrder.append(-1)
                } else {
                    actualOrder.append(stationList[column].number)
                }
            }
        } else { /// if there are pvp games
            let limit = pvp * 2 /// columns whose index is smaller than the limit colum are pvp games
            for column in order {
                /// no game for the round
                if column == -1{
                    actualOrder.append(0)
                }
                /// pvp games
                else if column < limit {
                    actualOrder.append(stationList[column / 2].number)
                }
                /// pve games
                else {
                    actualOrder.append(stationList[column - pvp].number)
                }
            }
        }
        return actualOrder
    }
    
    
}
// MARK: - UICollectionViewDelegate
extension CreateTeamViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) else {return}
        if selectedIndex == indexPath.item {
            collectionView.deselectItem(at: indexPath, animated: true)
            cell.layer.borderWidth = 0
            selectedIndex = nil
            cell.isSelected = false
        } else {
            selectedIndex = indexPath.row
            cell.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = cell.frame.size.width / 2
            cell.isSelected = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {return}
        cell.layer.borderWidth = 0
        selectedIndex = nil
        cell.isSelected = false
    }
}

// MARK: - UICollectionViewDataSource
extension CreateTeamViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconImageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamIconCollectionViewCell.identifier , for: indexPath) as! TeamIconCollectionViewCell
        cell.configureCreateTeamCell(iconImageNames[indexPath.item])
        if cell.isSelected == false {
            cell.layer.borderWidth = 0.0
        } else {
            cell.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = cell.frame.size.width / 2
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateTeamViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 65, height: 65)
    }
}

// MARK: - UITextFieldDelegate
extension CreateTeamViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == teamNameTextField {
            teamNumberTextField.becomeFirstResponder()
        } else if textField == teamNumberTextField {
            createTeamButtonPressed(createTeamButton)
        }
        return true
    }
}
