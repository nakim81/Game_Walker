//
//  PlayerFrame3_2.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/16/22.
//

import Foundation
import UIKit

class JoinTeamViewController: BaseViewController {
    
    @IBOutlet weak var joinTeamButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedIndex: Int?
    var teams: [Team] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        K.Database.delegates.append(self)
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(TeamIconCollectionViewCell.self, forCellWithReuseIdentifier: TeamIconCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        K.Database.getHost(gamecode: UserData.gamecode!)
    }



    @IBAction func joinTeamButtonPressed(_ sender: UIButton) {
        if let selectedIndex = selectedIndex {
            K.Database.setupRequest(gamecode: UserData.gamecode!, player: UserData.player, referee: nil, team: teams[selectedIndex], station: nil, gameTime: nil, movingTime: nil, rounds: nil, request: .joinTeam)

            performSegue(withIdentifier: "goToPF44", sender: self)
        } else {
            alert(title: "No Icon Selected", message: "Please select a team icon")
            return
        }
    }
}

// MARK: - UICollectionViewDelegate
extension JoinTeamViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TeamIconCollectionViewCell else { return }
            if selectedIndex == indexPath.row {
                collectionView.deselectItem(at: indexPath, animated: true)
                cell.layer.borderWidth = 0
                selectedIndex = nil
            } else {
                selectedIndex = indexPath.row
                cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
                cell.layer.borderWidth = 1
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TeamIconCollectionViewCell else { return }
        cell.layer.borderWidth = 0
        selectedIndex = nil
        print("\(cell.getImageName()) deselected")
    }
}

// MARK: - UICollectionViewDataSource
extension JoinTeamViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamIconCollectionViewCell.identifier , for: indexPath) as! TeamIconCollectionViewCell
        let team = teams[indexPath.item]
        cell.configureJoinTeamCell(imageName: team.iconName, teamName: team.name)
        //cell.setImage(with: iconImageNames[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension JoinTeamViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 110)
    }
}

//MARK: - UIUpdate
extension JoinTeamViewController: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
        teams = host.teams
        collectionView.reloadData()
    }
}

