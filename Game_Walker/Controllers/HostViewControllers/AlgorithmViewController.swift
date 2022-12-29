//
//  AlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/22.
//

import UIKit

class AlgorithmViewController: BaseViewController {
    var curr_gamecode = String(data: UserDefaults.standard.data(forKey: "gamecodestring")!, encoding: .utf8)!
    @IBOutlet weak var collectionView: UICollectionView!
    var stationsnum = S.getStationList(curr_gamecode).count
//var roundsnum = H.getHost(UserData.gamecode!).rounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        S.delegate_stationList = self
//        S.getStationList(UserData.gamecode!)
    }
    


}

