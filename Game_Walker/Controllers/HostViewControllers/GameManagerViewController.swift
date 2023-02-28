//
//  GameManagerViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/14/22.
//

import UIKit

class GameManagerViewController: UIViewController {
    
    var data = [
        ["1 2346", "Team 1", "ABCDEF"],
        ["2 2", "Team 2", "ABCDEF"],
    ]

    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    private var teamList: [Team] = []
    private let gameCode = UserData.readGamecode("gamecode") ?? ""
    private var selectedIndex: Int?
    private let refreshController: UIRefreshControl = UIRefreshControl()
    
    @IBAction func endButtonDragged(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegate_teamList = self
        configureCollectionView()
        T.getTeamList(gameCode)
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(GameManagerCollectionViewCell.self, forCellWithReuseIdentifier: GameManagerCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.refreshControl = refreshController
        settingRefreshControl()
    }
    
    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        refreshController.attributedTitle = NSAttributedString(string: "reloading,,,", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1), NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
    
    @objc func refreshFunction() {
        T.getTeamList(gameCode)
        refreshController.endRefreshing()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension GameManagerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GameManagerCollectionViewCell else { return }
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? GameManagerCollectionViewCell else { return }
        cell.layer.borderWidth = 0
        selectedIndex = nil
    }
}

// MARK: - UICollectionViewDataSource
extension GameManagerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameManagerCollectionViewCell.identifier , for: indexPath) as! GameManagerCollectionViewCell
        let team = teamList[indexPath.item]
        let teamNum = String(team.number)
        cell.configureGameManagerTeamCell(imageName: team.iconName, teamName: team.name, teamNum: "Team \(teamNum)")
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GameManagerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 130)
    }
}

//MARK: - TeamProtocols
extension GameManagerViewController: TeamList {
    func listOfTeams(_ teams: [Team]) {
        self.teamList = teams
        self.collectionView?.reloadData()
    }
}
