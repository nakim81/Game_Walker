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
    private var teamList: [Team] = []
    private var currentPlayer: Player = UserData.readPlayer("player") ?? Player()
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    
    private let audioPlayerManager = AudioPlayerManager()
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 42)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = false
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task { @MainActor in
            do {
                self.teamList = try await T.getTeamList(gameCode)
                self.teamList.sort{$0.number < $1.number}
                collectionView.reloadData()
            } catch {
                alert(title: "Connection Error", message: "Swipe down the screen again to reload team list!")
            }
        }
        configureCollectionView()
        configureGamecodeLabel()
        configureBtn()
    }
    
    private func configureBtn(){
        joinTeamButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        joinTeamButton.layer.cornerRadius = 8
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(TeamIconCollectionViewCell.self, forCellWithReuseIdentifier: TeamIconCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.refreshControl = refreshController
        settingRefreshControl()
    }
    
    private func configureGamecodeLabel() {
        view.addSubview(gameCodeLabel)
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (self.navigationController?.navigationBar.frame.minY)!),
        ])
    }
    
    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
        refreshController.attributedTitle = NSAttributedString(string: "reloading,,,", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1) , NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
    
    @objc func refreshFunction() {
        Task { @MainActor in
            do {
                self.teamList = try await T.getTeamList(gameCode)
                self.teamList.sort{$0.number < $1.number}
                refreshController.endRefreshing()
                collectionView.reloadData()
            } catch(let e) {
                print(e)
                alert(title: "Conncetion Error", message: e.localizedDescription)
                return
            }
        }
    }
    
    @IBAction func joinTeamButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        
        if let selectedIndex = selectedIndex {
            let selectedTeam = teamList[selectedIndex]
            UserData.writeTeam(selectedTeam, "team")
            Task { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                do {
                    try await T.joinTeam(strongSelf.gameCode, selectedTeam.name, strongSelf.currentPlayer)
                    strongSelf.performSegue(withIdentifier: "goToPF44", sender: strongSelf)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
            }
        } else {
            alert(title: "No Team Selected", message: "Please select your team")
            return
        }
    }
}

// MARK: - UICollectionViewDelegate
extension JoinTeamViewController: UICollectionViewDelegate {
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
            cell.layer.borderWidth = 2
            cell.layer.cornerRadius = 5
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
extension JoinTeamViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamIconCollectionViewCell.identifier , for: indexPath) as! TeamIconCollectionViewCell
        let team = teamList[indexPath.item]
        let teamNum = String(team.number)
        cell.configureJoinTeamCell(imageName: team.iconName, teamName: team.name, teamNum: "Team \(teamNum)")
        if cell.isSelected == true {
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
        } else {
            cell.layer.borderWidth = 0.0
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension JoinTeamViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 84, height: 130)
    }
}
