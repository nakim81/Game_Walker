//
//  AddStationViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/22/22.
//

import UIKit
import SwiftUI

class AddStationViewController: BaseViewController {

    @IBOutlet weak var gamenameTextfield: UITextField!
    @IBOutlet weak var gamelocationTextfield: UITextField!
    @IBOutlet weak var gamepointsTextfield: UITextField!
    @IBOutlet weak var refereeTextfield: UITextField!
    @IBOutlet weak var rulesTextfield: UITextField!
    
    @IBOutlet weak var pvpButton: UIButton!
    @IBOutlet weak var pveButton: UIButton!
    
    var pvpnotchosen = true
    var isPvp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gamenameTextfield.delegate = self
        gamelocationTextfield.delegate = self
        gamepointsTextfield.delegate = self
        refereeTextfield.delegate = self
        rulesTextfield.delegate = self
        gamepointsTextfield.keyboardType = .numberPad

        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    
//    func addNewCell(with name: String) {
//
//    }
//
    
    
    @IBAction func pvpChosen(_ sender: UIButton) {
        pvpnotchosen = false
        if pveButton.currentBackgroundImage == UIImage(named:"pve selected 1") {
            pveButton.setBackgroundImage(UIImage(named:"pve 1"), for:.normal)
        }
        pvpButton.setBackgroundImage(UIImage(named:"pvp selected 1"), for: .normal)
        isPvp = true
    }
    
    @IBAction func pveChosen(_ sender: UIButton) {
        pvpnotchosen = false
        if pvpButton.currentBackgroundImage == UIImage(named:"pvp selected 1") {
            pvpButton.setBackgroundImage(UIImage(named:"pvp 1"), for:.normal)
        }
        pveButton.setBackgroundImage(UIImage(named:"pve selected 1"), for: .normal)
        isPvp = false
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        var gamename = ""
        var gamelocation = ""
        var gamepoints = 0
        var referee = ""
        var rules = ""
        if (gamenameTextfield.text!.isEmpty) {
            alert(title:"No Game Name",message:"Please enter the game name.")
        } else {
            gamename = gamenameTextfield.text!
        }
        if (gamelocationTextfield.text!.isEmpty) {
            alert(title:"No Game Location",message:"Please enter the game location.")
        } else {
            gamelocation = gamelocationTextfield.text!
        }
        if (gamepointsTextfield.text!.isEmpty) {
            alert(title:"No Game Points",message:"Please set the game points.")
        } else {
            gamepoints = Int(gamepointsTextfield.text!)!
        }
        if (refereeTextfield.text!.isEmpty) {
            alert(title:"No Referee Selected",message:"Please assign a referee.")
        } else {
            referee = refereeTextfield.text!
        }
        if (rulesTextfield.text!.isEmpty) {
            alert(title:"No Game Rules",message:"Please enter the game rules.")
        } else {
            rules = rulesTextfield.text!
        }
        if (pvpnotchosen) {
            alert(title:"Game Type Not Specified", message: "Please select either PVP or PVE")
        }
        
        
        let ref = Referee(gamecode: UserData.gamecode!, name: referee, stationName: gamename, assigned: true)
        let stationToAdd = Station(name:UserData.gamecode!, pvp: isPvp, points: gamepoints, place: gamelocation, description: rules, referee: ref)
        
        S.addStation(gamecode: UserData.gamecode!, station: stationToAdd)
    }
    
}

extension AddStationViewController: UITextFieldDelegate {
    
}
