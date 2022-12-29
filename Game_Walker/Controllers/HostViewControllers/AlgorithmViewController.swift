//
//  AlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/22.
//

import UIKit

class AlgorithmViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var stationsnum = S.getStationList(UserData.gamecode!).count
//var roundsnum = H.getHost(UserData.gamecode!).rounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        S.delegate_stationList = self
//        S.getStationList(UserData.gamecode!)
    }
    


}

