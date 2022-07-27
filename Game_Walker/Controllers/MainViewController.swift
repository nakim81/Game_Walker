//
//  ViewController.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let blank = Station()
        let st = Station(name: "CatchMind", pvp: true, points: 50, place: "house", description: "win", teams: [])
        
        let test1 = Referee(gamecode: "123456", name: "Noah", stationName: blank.name)
        let test2 = Referee(gamecode: "123456", name: "Paul", stationName: blank.name)
        //R.addReferee("123456", test1)
        //R.addReferee("123456", test2)
        R.assignStation("123456", test2, st)
        
    }
    
    func listen(_ _ : [String : Any]){
    }

}


