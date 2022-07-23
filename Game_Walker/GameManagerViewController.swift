//
//  GameManagerViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/14/22.
//

import UIKit

class GameManagerViewController: BaseViewController {
    
    var data = [
        ["1 2346", "Team 1", "ABCDEF"],
        ["2 2", "Team 2", "ABCDEF"],
    ]

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "GameManagerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GameManagerCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension GameManagerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameManagerCollectionViewCell", for: indexPath) as? GameManagerCollectionViewCell else { return UICollectionViewCell() }
        
        let cellData = data[indexPath.row]
        cell.configure(imageName: cellData[0], teamName: cellData[1], hostName: cellData[2])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
}
