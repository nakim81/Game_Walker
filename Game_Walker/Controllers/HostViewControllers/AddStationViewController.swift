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
    @IBOutlet weak var rulesTextfield: UITextField!
    @IBOutlet weak var refereeTableView: UITableView!
    
    @IBOutlet weak var pvpButton: UIButton!
    @IBOutlet weak var pveButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var refereeLabel: UILabel!
    
    var pvpnotchosen = true
    var isPvp = false
    var availableReferees : [Referee] = []
    var gamename = ""
    var gamelocation = ""
    var gamepoints = 0
    var refereename = ""
    var isdropped = false
    var rules = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gamenameTextfield.delegate = self
        gamelocationTextfield.delegate = self
        gamepointsTextfield.delegate = self
        rulesTextfield.delegate = self
        gamepointsTextfield.keyboardType = .numberPad
        
        refereeTableView.delegate = self
        refereeTableView.dataSource = self
        refereeTableView.register(UINib(nibName: "StationRefereeTableViewCell", bundle: nil), forCellReuseIdentifier: "StationRefereeTableViewCell")
        refereeTableView.isHidden = true
        
        checkReferee()
        R.delegate_refereeList = self
        R.getRefereeList(UserData.gamecode!)
        
        self.hideKeyboardWhenTappedAround()
    }

      
    func checkReferee() {
        if refereename == "" {
            refereeLabel.text = "Choose Referee"
        } else{
            refereeLabel.text = refereename
        }
        refereeLabel.font = UIFont(name:"Dosis", size: 20.0)
    }
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
        if (rulesTextfield.text!.isEmpty) {
            alert(title:"No Game Rules",message:"Please enter the game rules.")
        } else {
            rules = rulesTextfield.text!
        }
        if (pvpnotchosen) {
            alert(title:"Game Type Not Specified", message: "Please select either PVP or PVE")
        }
        
        let selectedReferee = Referee(gamecode:UserData.gamecode!, name: refereename, stationName: gamename,assigned: true)
        R.assignStation(UserData.gamecode!, selectedReferee, gamename)
        let stationToAdd = Station(name:UserData.gamecode!, pvp: isPvp, points: gamepoints, place: gamelocation, description: rules)
        S.addStation(UserData.gamecode!, stationToAdd)
    }
    
    
    @IBAction func refereeButtonPressed(_ sender: UIButton) {
        dropRefereeList(dropped: isdropped)
        self.refereeTableView.reloadData()
    }
    
    func dropRefereeList(dropped: Bool) {
        if dropped {
            UIView.animate(withDuration:0.3) {
                self.refereeTableView.isHidden = true
                self.isdropped = false
                self.pvpButton.isEnabled = true
                self.pveButton.isEnabled = true
                self.rulesTextfield.isEnabled = true
                self.saveButton.isEnabled = true
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.refereeTableView.isHidden = false
                self.isdropped = true
                self.pvpButton.isEnabled = false
                self.pveButton.isEnabled = false
                self.rulesTextfield.isEnabled = false
                self.saveButton.isEnabled = false
            }
        }
    }
    
}


extension AddStationViewController: UITextFieldDelegate {

}

extension AddStationViewController: UITableViewDelegate {

}

extension AddStationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(availableReferees.count)
        return availableReferees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = refereeTableView.dequeueReusableCell(withIdentifier: "StationRefereeTableViewCell", for: indexPath) as! StationRefereeTableViewCell
        let curr_cellname = availableReferees[indexPath.row].name
        cell.configureRefereeCell(refereeName: curr_cellname)
        print(curr_cellname)
        return cell
    }
    
    
}


extension AddStationViewController: RefereeList {
    func listOfReferees(_ referees: [Referee]) {
        for referee in referees {
            if (!referee.assigned) {
                availableReferees.append(referee)
                print(availableReferees)
            }
        }
    }
}
