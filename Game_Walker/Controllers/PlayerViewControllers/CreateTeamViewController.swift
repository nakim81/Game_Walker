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
    private var stationList: [Station] = []
    private var algorithm: [[Int]] = []
    
    private let audioPlayerManager = AudioPlayerManager()
    
    private let iconImageNames : [String] = [
        "iconBoy", "iconBear", "iconJam-min", "iconGeum-jjok", "iconGirl", "iconBunny", "iconPenguin", "iconDuck", "iconSheep", "iconMonkey", "iconCat", "iconPig", "iconPanda", "iconWholeApple", "iconCutApple", "iconCherry", "iconDaisy", "iconpeas", "iconPea 1", "iconPlant", "iconAir",
        "iconDust", "iconFire", "iconWater", "iconRed", "iconOrance", "iconYellow", "iconGreen", "iconBlue",
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
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 31)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code" + "\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 10) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var selectedIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamNameTextField.delegate = self
        teamNameTextField.delegate = self
        configureCollectionView()
        configureDelegates()
        configureGamecodeLabel()
        self.stationList = [Station(name: "game1", number: 1, pvp: true), Station(name: "game2", number: 2, pvp: true), Station(name: "game3", number: 3, pvp: true)]
        print(self.stationList)
        print(self.algorithm, self.algorithm.count)
    }
    
    private func configureDelegates() {
        H.delegate_getHost = self
        S.delegate_stationList = self
    }
    
    private func listen(_ _ : [String : Any]){}
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.register(TeamIconCollectionViewCell.self, forCellWithReuseIdentifier: TeamIconCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.clipsToBounds = false
    }
    
    private func configureGamecodeLabel() {
        view.addSubview(gameCodeLabel)
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.058),
            gameCodeLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.04),
            gameCodeLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2)
        ])
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
        H.getHost(gameCode)
        if Int(teamNumber) ?? 0 > 0 {
            if !self.algorithm.isEmpty {
                teamNameTextField.resignFirstResponder()
                guard let selectedIconName = selectedIconName else {
                    alert(title: "No Icon Selected", message: "Please select a team icon")
                    return
                }
                ///find the order of stations for player's team
                let stationOrder = self.getStationOrder(self.algorithm, Int(teamNumber) ?? 0)
                print("stationorder\(stationOrder)")
                let newTeam = Team(gamecode: gameCode, name: teamName, number: Int(teamNumber) ?? 0, players: [currentPlayer], points: 0, stationOrder: stationOrder, iconName: selectedIconName)
                UserData.writeTeam(newTeam, "team")
                Task { @MainActor in
                    await T.addTeam(gameCode, newTeam)
                    performSegue(withIdentifier: "goToTPF4", sender: self)
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
    
    ///return the order of staions for the team
    private func getStationOrder(_ algorithm: [[Int]], _ teamNumber: Int) -> [Int] {
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
                if index == teams.count {
                    order.append(-1)
                }
            }
            ///reset search index when moving to the next row
            index = 0
        }
        print("column order: \(order)")
        let pvp = self.findNumberOfPVP() ///number of pvp games
        var actualOrder: [Int] = [] //array of station.numbers
        
        /// if no pvp game, then order = actualOrder
        if pvp == 0 {
            for column in order {
                if column == -1 {
                    actualOrder.append(-1)
                } else {
                    actualOrder.append(self.stationList[column].number)
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
                    actualOrder.append(self.stationList[column / 2].number)
                }
                /// pve games
                else {
                    actualOrder.append(self.stationList[column - pvp].number)
                }
            }
        }
        return actualOrder
    }
    
    /// find the number of pvp games
    private func findNumberOfPVP() -> Int {
        var pvp = 0
        for station in self.stationList {
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
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
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
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = cell.frame.size.width / 2
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateTeamViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
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

// MARK: - Station Protocol
extension CreateTeamViewController: StationList, GetHost {
    func getHost(_ host: Host) {
        self.algorithm = host.algorithm
    }
    
    func listOfStations(_ stations: [Station]) {
        self.stationList = stations
    }
}
