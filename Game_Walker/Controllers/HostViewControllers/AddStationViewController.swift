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
    @IBOutlet weak var rulesTextfield: UITextView!
//    @IBOutlet weak var refereeTableView: UITableView!
    
    @IBOutlet weak var pvpButton: UIButton!
    @IBOutlet weak var pveButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var refereeLabel: UILabel!
    
    weak var stationsTableViewController: StationsTableViewController?
    
    var pvpnotchosen = true
    var isPvp = false
    var availableReferees : [Referee] = []
    var gamename = ""
    var gamelocation = ""
    var gamepoints = 0
    var refereename = ""
    var isdropped = false
    var rules = ""
    
    let transparentView = UIView()
    let refereeTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gamenameTextfield.delegate = self
        gamelocationTextfield.delegate = self
        gamepointsTextfield.delegate = self
        rulesTextfield.delegate = self
        gamepointsTextfield.keyboardType = .numberPad
        
//        refereeTableView.delegate = self
//        refereeTableView.dataSource = self
//        refereeTableView.register(UINib(nibName: "StationRefereeTableViewCell", bundle: nil), forCellReuseIdentifier: "StationRefereeTableViewCell")
//        refereeTableView.isHidden = true
        
        checkReferee()
        setPaddings()
        R.delegate_refereeList = self
        R.getRefereeList(UserData.readGamecode("gamecodestring")!)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender as? StationsTableViewController else { return }
        stationsTableViewController = sender
    }

    func addTransparentView(frames : CGRect) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        //adding table view when button pressed
        refereeTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0 )
        self.view.addSubview(refereeTableView)
        refereeTableView.layer.cornerRadius = 5
        
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        
        //create anmiation
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.refereeTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: self.refereeButton.frame.height * 6)
        }, completion: nil)
         
    }
    
    @objc func removeTransparentView() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.refereeTableView.frame = CGRect(x: self.refereeButton.frame.origin.x, y: self.refereeButton.frame.origin.y + self.refereeButton.frame.height, width: self.refereeButton.frame.width, height: 0)
        }, completion: nil)
    }
    
    func checkReferee() {
        if refereename == "" {
            refereeLabel.text = "Choose Referee"
        } else{
            refereeLabel.text = refereename
        }
        refereeLabel.font = UIFont(name:"Dosis", size: 20.0)
    }
    
    func setPaddings() {
        let padding: CGFloat = 10.0
        gamenameTextfield.setPadding(left: padding, right: padding)
        gamelocationTextfield.setPadding(left: padding, right: padding)
        gamepointsTextfield.setPadding(left: padding, right: padding)
        rulesTextfield.textContainerInset = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
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
        
        let selectedReferee = Referee(gamecode:UserData.readGamecode("gamecodestring")!, name: refereename, stationName: gamename,assigned: true)
        R.assignStation(UserData.readGamecode("gamecodestring")!, selectedReferee, gamename)
        let stationToAdd = Station(name:gamename, pvp: isPvp, points: gamepoints, place: gamelocation, description: rules)
        S.addStation(UserData.readGamecode("gamecodestring")!, stationToAdd)
        
        stationsTableViewController?.reloadStationTable()
    }
    
    
    @IBAction func refereeButtonPressed(_ sender: UIButton) {
        dropRefereeList(dropped: isdropped)
//        self.refereeTableView.reloadData()
        addTransparentView(frames: refereeButton.frame)
    }
    
    func dropRefereeList(dropped: Bool) {
        if dropped {
            UIView.animate(withDuration:0.3) {
//                self.refereeTableView.isHidden = true
                self.isdropped = false
                self.pvpButton.isHidden = false
                self.pveButton.isHidden = false
                self.rulesTextfield.isHidden = false
                self.saveButton.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
//                self.refereeTableView.isHidden = false
                self.isdropped = true
                self.pvpButton.isHidden = true
                self.pveButton.isHidden = true
                self.rulesTextfield.isHidden = true
                self.saveButton.isHidden = true
            }
        }
    }
    
    
}


extension AddStationViewController: UITextFieldDelegate {

}

extension AddStationViewController: UITextViewDelegate {
    
}

//
//extension AddStationViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return availableReferees.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = refereeTableView.dequeueReusableCell(withIdentifier: "StationRefereeTableViewCell", for: indexPath) as! StationRefereeTableViewCell
//        let curr_cellname = availableReferees[indexPath.row].name
//        cell.configureRefereeCell(refereeName: curr_cellname)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        print(availableReferees[indexPath.row])
//        refereename = availableReferees[indexPath.row].name
//        print(refereename)
//        checkReferee()
//        dropRefereeList(dropped: isdropped)
//    }
//
//}



extension AddStationViewController: RefereeList {
    func listOfReferees(_ referees: [Referee]) {
        for referee in referees {
            if (!referee.assigned) {
                availableReferees.append(referee)
//                print(availableReferees)
            }
        }
    }
}


