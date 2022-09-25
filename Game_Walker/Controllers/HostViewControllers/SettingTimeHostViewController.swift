//
//  SettingTimeHostViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 9/24/22.
//

import UIKit
import SwiftUI

class SettingTimeHostViewController: UIViewController {

    @IBOutlet weak var gameMinutesLabel: UILabel!
    @IBOutlet weak var gameSecondsLabel: UILabel!
    @IBOutlet weak var movingMinutesLabel: UILabel!
    @IBOutlet weak var movingSecondsLabel: UILabel!
    @IBOutlet weak var roundsLabel: UILabel!
    
    @State var minutes = 0
    @State var seconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}
