//
//  PlayerFrame3_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/16/22.
//

import Foundation
import UIKit

class PlayerFrame3_1: BaseViewController {
    
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var createTeamButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let iconImages : [String] = [
         "1 2346",
         "2 2",
         "3 1",
         "4 1",
         "5",
         "6",
         "7",
         "8",
         "a",
         "b",
         "c",
         "d",
         "e",
         "f",
         "g",
         "h",
         "i",
         "j",
         "k",
         "l",
    ]
    
    var selectedIconName: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        teamNameTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 20, height: 20)
        collectionView.collectionViewLayout = layout
        
        collectionView.register(IconCollectionViewCell.nib(), forCellWithReuseIdentifier: IconCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    @IBAction func createTeamButtonPressed(_ sender: UIButton) {
        
        teamNameTextField.resignFirstResponder()
        
        guard let selectedIconName = selectedIconName else {
            alert(title: "No Icon Selected", message: "Please select a team icon")
            return
        }

        if let teamName: String = teamNameTextField.text, !teamName.isEmpty {
            let newTeam = Team(name: teamName, players: [], points: 0, currentStation: "", nextStation: "", iconName: selectedIconName)
            print(newTeam)
            K.Database.setupRequest(gamecode: "", player: nil, referee: nil, team: newTeam, station: nil, gameTime: nil, movingTime: nil, rounds: nil, request: .addPlayer)

            performSegue(withIdentifier: "goToTPF4", sender: self)
        } else {
            alertUserTeamError()
        }
    }
    
    func alertUserTeamError() {
        let alert = UIAlertController(title: "Woops", message: "Please enter team name to create your team", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension PlayerFrame3_1: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? IconCollectionViewCell else { return }
        
        cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
<<<<<<< HEAD
        cell.layer.borderWidth = 1
=======
        cell.layer.borderWidth = 5
>>>>>>> b63cdbd (changed)
        selectedIconName = cell.imageName
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me")
    }
}

// MARK: - UICollectionViewDataSource
extension PlayerFrame3_1: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCollectionViewCell.identifier , for: indexPath) as! IconCollectionViewCell
        
        cell.setImage(with: iconImages[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PlayerFrame3_1: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}

// MARK: - UITextFieldDelegate
extension PlayerFrame3_1: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == teamNameTextField {
            teamNameTextField.resignFirstResponder()
        }
        return true
    }
}
