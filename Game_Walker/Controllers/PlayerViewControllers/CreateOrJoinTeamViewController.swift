//
//  PlayerFrame2.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/15/22.
//

import Foundation
import UIKit


class CreateOrJoinTeamViewController: BaseViewController {
    
    @IBOutlet weak var creatTeamButton: UIButton!
    @IBOutlet weak var joinTeamButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func creatTeamButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPF3_1VC", sender: self)
    }
    
    @IBAction func joinTeamButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPF3_2VC", sender: self)
    }
}
