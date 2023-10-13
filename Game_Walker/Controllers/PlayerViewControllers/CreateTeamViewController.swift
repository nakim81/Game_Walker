//
//  PlayerFrame3_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/16/22.
//

import Foundation
import UIKit

class CreateTeamViewController: BaseViewController {
    
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var teamNumberTextField: UITextField!
    @IBOutlet weak var createTeamButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var currentPlayer = UserData.readPlayer("player") ?? Player()
    private var gameCode = UserData.readGamecode("gamecode") ?? ""
    private var host: Host?
    private var stationList: [Station] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
        configureTextField()
        configureCollectionView()
        configureBtn()
        configureNavItem()
    }
    
    func configureNavItem() {
        let settingBtnImage = UIImage(named: "settingIcon")?.withRenderingMode(.alwaysTemplate)
        let rightButton = UIBarButtonItem(image: settingBtnImage, style: .plain, target: self, action: #selector(setting))
        rightButton.tintColor = UIColor(red: 0.267, green: 0.659, blue: 0.906, alpha: 1)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func setting(sender: UIBarButtonItem) {
        
    }
    
    private func configureTextField(){
        teamNameTextField.layer.cornerRadius = 10
        teamNameTextField.layer.borderWidth = 3
        teamNameTextField.layer.borderColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 1).cgColor
        teamNumberTextField.layer.cornerRadius = 10
        teamNumberTextField.layer.borderWidth = 3
        teamNumberTextField.layer.borderColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 1).cgColor
    }
    
    private func configureDelegates() {
        teamNameTextField.delegate = self
        teamNumberTextField.delegate = self
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
    
    private func configureBtn(){
        createTeamButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        createTeamButton.layer.cornerRadius = 8
    }
    
    @IBAction func createTeamButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        
        guard let teamName = teamNameTextField.text, !teamName.isEmpty else {
            alert(title: "Team Name Error", message: "Team name should exist! Fill out the team name box")
            return
        }
        guard let teamNumber = teamNumberTextField.text, !teamNumber.isEmpty else {
            alert(title: "Team Number Error", message: "Team number should exist! Fill out the team number box")
            return
        }
        Task { @MainActor in
            do {
                self.host = try await H.getHost(gameCode)
                self.stationList = try await S.getStationList(gameCode)
            } catch(let e) {
                print(e)
                alert(title: "Connection Error", message: e.localizedDescription)
                return
            }
        }
        //H.getHost(gameCode)
        if Int(teamNumber) ?? 0 > 0 {
            guard let temp = self.host?.algorithm else { return }
            let algorithm = convert1DArrayTo2D(temp)
            print(algorithm)
            if !(algorithm.isEmpty ) {
                teamNameTextField.resignFirstResponder()
                guard let selectedIconName = selectedIconName else {
                    alert(title: "No Icon Selected", message: "Please select a team icon")
                    return
                }
                ///find the order of stations for player's team
                let stationOrder = self.getStationOrder(algorithm , Int(teamNumber) ?? 0, self.stationList)
                print("stationorder: \(stationOrder)")
                let newTeam = Team(gamecode: gameCode, name: teamName, number: Int(teamNumber) ?? 0, players: [currentPlayer], points: 0, stationOrder: stationOrder, iconName: selectedIconName)
                UserData.writeTeam(newTeam, "team")
                Task { @MainActor in
                    do {
                        try await T.addTeam(gameCode, newTeam)
                        performSegue(withIdentifier: "goToTPF4", sender: self)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
            } else {
                alert(title: "", message: "The game has not started yet. Please try few minutes later!")
                return
            }
        } else {
            alert(title: "Team Number Error", message: "Team number should be greater than 0!")
            return
        }
    }
    
    private func listen(_ _ : [String : Any]){}
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
        print("column order: \(order)")
        let pvp = self.findNumberOfPVP(stationList) ///number of pvp games
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
    
    /// find the number of pvp games
    private func findNumberOfPVP(_ stationList: [Station]) -> Int {
        var pvp = 0
        for station in stationList {
            if station.pvp {
                pvp += 1
            }
        }
        return pvp
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
