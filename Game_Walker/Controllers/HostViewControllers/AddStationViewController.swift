//
//  AddStationViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/22/22.
//

import UIKit
import SwiftUI

class AddStationViewController: BaseViewController {

    @IBOutlet var fullview: UIView!
    @IBOutlet weak var guideContainerView: UIView!
    @IBOutlet weak var pvpPveContainerView: UIView!
    
    @IBOutlet weak var popupImageView: UIImageView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var gamenameTextfield: UITextField!
    @IBOutlet weak var gamelocationTextfield: UITextField!
    @IBOutlet weak var gamepointsTextfield: UITextField!
    @IBOutlet weak var rulesTextfield: UITextView!
    
    @IBOutlet weak var pvpButton: UIButton!
    @IBOutlet weak var pveButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var refereeLabel: UILabel!
    
    weak var stationsTableViewController: StationsTableViewController?
    
    weak var delegate: AddStationDelegate?

    var gamecode = UserData.readGamecode("gamecode")!
    var stationUuid = ""
    var tempStationUuid = ""
    
    var stationExists = false
    var modified = false
    var station : Station?
    
    var pvpnotchosen = true
    var isPvp = false
    var availableReferees : [Referee] = []
    var allReferees: [Referee] = []
    var gamename = ""
    var gamelocation = ""
    var gamepoints = 0
    
    var refereename = ""
    var refereeUuid = ""
    var refereeModified = false
    
    var isdropped = false
    var rules = ""
    
    let refereeTableView = UITableView()
    let transparentView = UIView()
    
    var refereeBefore : Referee?
    var newReferee : Referee?
    var stationToReplace : Station?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gamenameTextfield.delegate = self
        gamelocationTextfield.delegate = self
        gamepointsTextfield.delegate = self
        rulesTextfield.delegate = self
        gamepointsTextfield.keyboardType = .numberPad


        
        refereeTableView.register(UINib(nibName: "StationRefereeTableViewCell", bundle: nil), forCellReuseIdentifier: "StationRefereeTableViewCell")
        refereeTableView.delegate = self
        refereeTableView.dataSource = self
//        R.delegate_refereeList = self
//        R.getRefereeList(gamecode)
        Task { @MainActor in
            do {
                allReferees = try await R.getRefereeList(gamecode)
                for referee in allReferees {
                    if (!referee.assigned) {
                        availableReferees.append(referee)
                    }
                }
                
                if stationExists {
                    stationUuid = station!.uuid
                    
                    gamenameTextfield.attributedPlaceholder = NSAttributedString(string: station!.name, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
                    gamename = station!.name
                    
                    gamelocationTextfield.attributedPlaceholder = NSAttributedString(string: station!.place, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
                    gamelocation = station!.place
                    
                    gamepointsTextfield.attributedPlaceholder = NSAttributedString(string: String(station!.points), attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
                    rulesTextfield.text = station?.description
                    rules = station?.description ?? ""
                    gamepoints = station!.points
                    
                    pvpnotchosen = false
                    if (station?.pvp == true) {
                        pvpButton.sendActions(for: .touchUpInside)
                        isPvp = true
                        modified = true
                    } else {
                        pveButton.sendActions(for: .touchUpInside)
                        isPvp = false
                        modified = true
                    }
                    //change to -> station?.referee!.uuid
                    //and compare with uuids.
                    // for every Referee.uuid == uuid
                    
                    refereename = (station?.referee!.name)!
                    refereeUuid = (station?.referee!.uuid)!
                    refereeBefore = findRefereeWithUuid(refereeList: allReferees, uuidToCheck: refereeUuid)
                    print("refereeList.count : ", allReferees.count)
                    checkReferee()
                    setPaddings()

                }
            } catch(let e) {
                print(e)
                return
            }
        }

    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender as? StationsTableViewController else { return }
        stationsTableViewController = sender
    }
    
    func findRefereeWithUuid(refereeList: [Referee], uuidToCheck: String) -> Referee? {
        for referee in refereeList {
            if referee.uuid == uuidToCheck {
                return referee
            }
        }
        return nil
    }

    func addRefereeTable() {

        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        self.view.addSubview(refereeTableView)
        refereeTableView.layer.cornerRadius = 15

        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeRefereeTable))
        transparentView.addGestureRecognizer(tapgesture)
//        transparentView.alpha = 0
        
        //create anmiation
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.refereeTableView.alpha = 0.8
            
            self.giveConstraints()
        }, completion: nil)
         
    }
    
    func giveConstraints() {
//        transparentView.translatesAutoresizingMaskIntoConstraints = false
        refereeTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            refereeTableView.centerXAnchor.constraint(equalTo: refereeButton.centerXAnchor),
            refereeTableView.topAnchor.constraint(equalTo: refereeButton.bottomAnchor),
            refereeTableView.widthAnchor.constraint(equalTo: refereeButton.widthAnchor),
            refereeTableView.heightAnchor.constraint(equalTo: refereeButton.heightAnchor, multiplier: 6)
        ])
    }
    
    @objc func removeRefereeTable() {
        if (isdropped) {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.transparentView.alpha = 0
                self.refereeTableView.alpha = 0
            }, completion: nil)
            isdropped = false
        }

    }
    


    
    func checkReferee() {
        if refereename == "" && !stationExists{
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
        rulesTextfield.textContainerInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
    }
    
    @IBAction func pvpChosen(_ sender: UIButton) {
        pvpnotchosen = false
        
        if pveButton.currentBackgroundImage == UIImage(named:"PVE selected") {
            pveButton.setBackgroundImage(UIImage(named:"PVEButton"), for:.normal)
        }
        pvpButton.setBackgroundImage(UIImage(named:"PVP selected"), for: .normal)
        isPvp = true
    }
    
    @IBAction func pveChosen(_ sender: UIButton) {
        pvpnotchosen = false
        if pvpButton.currentBackgroundImage == UIImage(named:"PVP selected") {
            pvpButton.setBackgroundImage(UIImage(named:"PVPButton"), for:.normal)
        }
        pveButton.setBackgroundImage(UIImage(named:"PVE selected"), for: .normal)
        isPvp = false
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if !stationExists {
            if gamenameTextfield.text!.isEmpty {
                alert(title: "No Game Name", message: "Please enter the game name.")
                return
            }
            
            if gamepointsTextfield.text!.isEmpty {
                alert(title: "No Game Points", message: "Please set the game points.")
                return
            }
            
            if pvpnotchosen {
                alert(title: "Game Type Not Specified", message: "Please select either PVP or PVE")
                return
            }

            if refereeUuid.isEmpty {
                alert(title: "No Referee Selected", message: "Please select a referee.")
                return
            }
            
            gamename = gamenameTextfield.text!
            gamepoints = Int(gamepointsTextfield.text!)!
            gamelocation = gamelocationTextfield.text ?? ""
            rules = rulesTextfield.text ?? ""
        }
        
        if (stationExists && !modified) {
            self.dismiss(animated: true, completion: nil)
        } else if (stationExists && modified) {
            Task { @MainActor in
                //unassign station from referee 
            
                var tempReferee = findRefereeWithUuid(refereeList: allReferees, uuidToCheck: refereeUuid)

                if (refereeModified) {
                    do{
                        try await R.assignStation(gamecode, refereeBefore!.uuid, "", false)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                    do{
                        try await R.assignStation(gamecode, newReferee!.uuid, gamename, true)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                    tempReferee = findRefereeWithUuid(refereeList: availableReferees, uuidToCheck: newReferee!.uuid)
                }
                
                
                let modifiedStation = Station(uuid: stationUuid, name:gamename, pvp: isPvp, points: gamepoints, place: gamelocation, referee : tempReferee, description: rules)
                
                do {
                    try await S.saveStation(gamecode, modifiedStation)
                    NotificationCenter.default.post(name: Notification.Name("stationUpdate"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
            }

        } else if (!stationExists) {
            let selectedReferee = findRefereeWithUuid(refereeList: availableReferees, uuidToCheck: refereeUuid)
            Task { @MainActor in
                do {
                    try await R.assignStation(gamecode, refereeUuid, gamename, true)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
                
                let uuid = UUID()
                stationUuid = uuid.uuidString
                
                let stationToAdd = Station(uuid: stationUuid, name:gamename, pvp: isPvp, points: gamepoints, place: gamelocation, referee : selectedReferee, description: rules)

                do {
                    try await S.saveStation(gamecode, stationToAdd)

                    delegate?.didUpdateStationData {
                        print("delegate is being called")
                        NotificationCenter.default.post(name: .stationDataUpdated, object: nil)
                    }

                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
            }
        }

        self.dismiss(animated: true, completion: nil)

    }
    
    
    
    @IBAction func refereeButtonPressed(_ sender: UIButton) {

        if (!isdropped) {
            addRefereeTable()
            isdropped = true
        } else {
            removeRefereeTable()
            isdropped = false
        }
    }
    
    @IBAction func getGuideButtonPressed(_ sender: UIButton) {
        let overlay = OverlayGuideView(frame : popupImageView.frame)
        overlay.giveCornerRadius(of: CGFloat(20))
        popupView.addSubview(overlay)
        let refereeOverlay = OverlayComponentView(frame : refereeButton.frame)
        refereeOverlay.addLabel(with: "No Referees yet? Share the game code.", width: refereeButton.frame.width)
        popupView.addSubview(refereeOverlay)
        

        let pvpButtonFrameInPopupView = pvpPveContainerView.convert(pvpButton.frame, to: popupView)
        let pveButtonFrameInPopupView = pvpPveContainerView.convert(pveButton.frame, to: popupView)
        
        let pvpOverlay = OverlayComponentView(frame: pvpButtonFrameInPopupView)
        let pveOverlay = OverlayComponentView(frame: pveButtonFrameInPopupView)

        pvpOverlay.addLabel(with: "PVP for competition", width: pvpButton.frame.width)
        pveOverlay.addLabel(with: "PVE for goals.", width : pveButton.frame.width)
        
        popupView.addSubview(pvpOverlay)
        popupView.addSubview(pveOverlay)
        
        overlay.onCloseButtonTapped = { [weak overlay] in
            overlay?.removeFromSuperview()
            refereeOverlay.removeFromSuperview()
            pvpOverlay.removeFromSuperview()
            pveOverlay.removeFromSuperview()
        }
    }
    
    
    
}


extension AddStationViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // check if content changed
        if stationExists {
            if textField == gamenameTextfield {
                let newGameName = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
                gamename = newGameName
                print("gamename: ", gamename)
            } else if textField == gamelocationTextfield {
                let newGameLocation = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
                gamelocation = newGameLocation
                print("gamelocation: ", gamelocation)
            } else if textField == gamepointsTextfield {
                let points = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
                if let newGamePoints = Int(points) {
                    gamepoints = newGamePoints
                    print("gamepoints : ", gamepoints)
                } else {
                    alert(title: "", message: "gamepoints should be an integer")
                }
            }
            modified = true
        }
        return true
    }
}

extension AddStationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if stationExists {
            modified = true
            // appends all text rules being typed in
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            
            rules = newText
            
//            print(rules)
        }
        return true
    }

}


extension AddStationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableReferees.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = refereeTableView.dequeueReusableCell(withIdentifier: "StationRefereeTableViewCell", for: indexPath) as! StationRefereeTableViewCell
        let curr_cellname = availableReferees[indexPath.row].name
        cell.configureRefereeCell(refereeName: curr_cellname)
        cell.refereenameLabel?.font = UIFont(name: "Dosis-Regular", size: 20.0)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedRefereeName = availableReferees[indexPath.row].name
        let selectedRefereeUuid = availableReferees[indexPath.row].uuid
        
        if stationExists && refereeUuid != selectedRefereeUuid {
            modified = true
            refereeModified = true
            refereeUuid = selectedRefereeUuid
            refereename = selectedRefereeName
            
            newReferee = findRefereeWithUuid(refereeList: allReferees, uuidToCheck: refereeUuid)

        }
//        print(refereename)
        checkReferee()
        if !stationExists {
            refereename = selectedRefereeName
            refereeUuid = selectedRefereeUuid
        }
//        refereeButton.setTitle(refereename, for: .normal)
        refereeLabel.text = refereename
        removeRefereeTable()
    }

}


