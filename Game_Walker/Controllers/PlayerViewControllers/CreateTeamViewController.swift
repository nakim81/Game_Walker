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
    
    private var selectedIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamNameTextField.delegate = self
        teamNameTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
        configureCollectionView()
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
    
    @IBAction func createTeamButtonPressed(_ sender: UIButton) {
        teamNameTextField.resignFirstResponder()
        guard let selectedIconName = selectedIconName else {
            alert(title: "No Icon Selected", message: "Please select a team icon")
            return
        }
        if let teamName: String = teamNameTextField.text, !teamName.isEmpty, let teamNumber: String = teamNumberTextField.text, !teamNumber.isEmpty {
            let newTeam = Team(gamecode: gameCode, name: teamName, number: Int(teamNumber) ?? 0, players: [currentPlayer], points: 0, currentStation: "", nextStation: "", iconName: selectedIconName)
            UserData.writeTeam(newTeam, "team")
            T.addTeam(gameCode, newTeam)
            //Task {
                //try await Task.sleep(nanoseconds: 500_000_000)
                T.joinTeam(gameCode, newTeam.name, currentPlayer)
                performSegue(withIdentifier: "goToTPF4", sender: self)
            //}
        } else {
            alert(title: "Woops", message: "Please enter team name to create your team")
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CreateTeamViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TeamIconCollectionViewCell else { return }
            if selectedIndex == indexPath.row {
                collectionView.deselectItem(at: indexPath, animated: true)
                cell.hideBorder()
                selectedIndex = nil
            } else {
                selectedIndex = indexPath.row
                cell.showBorder()
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TeamIconCollectionViewCell else { return }
        cell.hideBorder()
        selectedIndex = nil
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
