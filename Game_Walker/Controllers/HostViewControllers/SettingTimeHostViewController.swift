//
//  SettingTimeHostViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 9/24/22.
//

import UIKit

class SettingTimeHostViewController: BaseViewController {

    
    @IBOutlet weak var gameMinutesLabel: UILabel!
    @IBOutlet weak var gameSecondsLabel: UILabel!
    @IBOutlet weak var movingMinutesLabel: UILabel!
    @IBOutlet weak var movingSecondsLabel: UILabel!
    @IBOutlet weak var roundsTextField: UITextField!
    @IBOutlet weak var teamcountTextField: UITextField!
    
//    var host: Host?
//    var team: Team?
    var gameminutes: Int = 20
    var gameseconds: Int = 0
    var moveminutes: Int = 10
    var moveseconds: Int = 0
    var teamcount: Int = 0
    var pickertype = 0
    var rounds : Int = 10
    
    private var gamecode = UserData.readGamecode("gamecodestring")!
    
    
    
    //UIPickerView inside of UIView container
    var gametimePickerView: UIView!
    var gametimePicker: UIPickerView!
    var movetimePickerView: UIView!
    var movetimePicker: UIPickerView!
    
    var currentPickerView: UIView!
    var currentPicker: UIPickerView!
    
    var gameToolBar = UIToolbar(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: 35))
    var moveToolBar = UIToolbar(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: 35))

    
    
    
    override func viewDidLoad() {

        
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        roundsTextField.keyboardType = .numberPad
        roundsTextField.textAlignment = .center
        roundsTextField.delegate = self
        teamcountTextField.keyboardType = .numberPad
        teamcountTextField.textAlignment = .center
        teamcountTextField.delegate = self
        
        gameMinutesLabel.text = String(gameminutes)
        movingMinutesLabel.text = String(moveminutes)
        
        gameToolBar.sizeToFit()
        moveToolBar.sizeToFit()
        let gamedoneButton = UIBarButtonItem(title: "Done", style: .done, target: self,  action: #selector(self.applyDone))
        let movedoneButton = UIBarButtonItem(title: "Done", style: .done, target: self,  action: #selector(self.applyDone))

        gameToolBar.setItems([gamedoneButton], animated: true)
        gameToolBar.isUserInteractionEnabled = true
        moveToolBar.setItems([movedoneButton], animated: true)
        moveToolBar.isUserInteractionEnabled = true


        gametimePickerView = UIView(frame: CGRect(x:0, y: view.frame.height + 260, width: view.frame.width, height: 260))
        movetimePickerView = UIView(frame: CGRect(x:0, y: view.frame.height + 260, width: view.frame.width, height: 260))
        
        view.addSubview(gametimePickerView)
        view.addSubview(movetimePickerView)
        
        gametimePickerView.translatesAutoresizingMaskIntoConstraints = false
        movetimePickerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            gametimePickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            gametimePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 260),
            gametimePickerView.heightAnchor.constraint(equalToConstant: 260),
            movetimePickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            movetimePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 260),
            movetimePickerView.heightAnchor.constraint(equalToConstant: 260)
        ])

        gametimePickerView.backgroundColor = .white
        movetimePickerView.backgroundColor = .white

        gametimePicker = UIPickerView(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.size.width, height: 260))
        movetimePicker = UIPickerView(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.size.width, height: 260))
        
        gametimePickerView.addSubview(gametimePicker)
        gametimePickerView.addSubview(gameToolBar)
        movetimePickerView.addSubview(movetimePicker)
        movetimePickerView.addSubview(moveToolBar)

        gametimePicker.isUserInteractionEnabled = true
        movetimePicker.isUserInteractionEnabled = true
        gametimePicker.delegate = self
        movetimePicker.delegate = self
        gametimePicker.dataSource = self
        movetimePicker.dataSource = self
        
        
        
    }
    
    @IBAction func gametimePressed(_ sender: UIButton) {
        pickertype = 0
        pickerAppear()
    }
    
    @IBAction func movetimePressed(_ sender: UIButton) {
        pickertype = 1
        pickerAppear()
    }
    
    @objc func applyDone() {
        self.view.endEditing(true)
        self.gametimePickerView.endEditing(true)
        pickerDisappear()
        self.gameMinutesLabel.text = changeTimeToString(timeInteger: gameminutes )
        self.gameSecondsLabel.text = changeTimeToString(timeInteger: gameseconds )
        
        self.movetimePickerView.endEditing(true)
        pickerDisappear()
        self.movingMinutesLabel.text = changeTimeToString(timeInteger: moveminutes )
        self.movingSecondsLabel.text = changeTimeToString(timeInteger: moveseconds )
    }
    
    func changeTimeToString(timeInteger : Int) -> String{
        var timeString = ""
        if (timeInteger < 10) {
            timeString = "0" + String(timeInteger)
        } else {
            timeString = String(timeInteger)
        }
        return timeString
    }
    
    func pickerAppear() {
        if (pickertype == 0) {
            UIView.animate(withDuration: 0.3, animations: {
                self.gametimePickerView.frame = CGRect(x:0, y: self.view.bounds.height - self.gametimePickerView.bounds.size.height, width: self.gametimePickerView.bounds.size.width, height: self.gametimePickerView.bounds.size.height)
                self.gametimePickerView.addSubview(self.gameToolBar)
               
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.movetimePickerView.frame = CGRect(x:0, y: self.view.bounds.height - self.movetimePickerView.bounds.size.height, width: self.movetimePickerView.bounds.size.width, height: self.movetimePickerView.bounds.size.height)
                self.movetimePickerView.addSubview(self.gameToolBar)
            })
        }
    }
    
    func pickerDisappear() {
        if (pickertype == 0) {
            UIView.animate(withDuration: 0.3, animations:{
                self.gametimePickerView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.gametimePickerView.bounds.size.width, height: self.gametimePickerView.bounds.size.height)
                self.gameToolBar.removeFromSuperview()
            })
        } else {
            UIView.animate(withDuration: 0.3, animations:{
                self.movetimePickerView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.movetimePickerView.bounds.size.width, height: 0)
                self.moveToolBar.removeFromSuperview()
            })
        }
    }
    
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        teamcountTextField.resignFirstResponder()
        roundsTextField.resignFirstResponder()
        if let rounds = roundsTextField.text, !rounds.isEmpty, let teamcount = teamcountTextField.text, !teamcount.isEmpty {
//            H.setTimer(gamecode, 110, 120, 13, 14)
            H.setTimer(gamecode,
                       timeConvert(min:gameminutes , sec:gameseconds ),
                       timeConvert(min:moveminutes , sec:moveseconds ),
                       Int(rounds) ?? 0,
                       Int(teamcount) ?? 0)

            print("ROUNDS AND TEAMCOUNT: ",rounds, teamcount)
            performSegue(withIdentifier: "SetAlgorithmSegue", sender: self)
//            performSegue(withIdentifier: "TempSegue", sender: self)
            
        } else {
            alert(title: "Woops", message: "Please enter all information to set timer")
        }
        
        H.listenHost(gamecode, onListenerUpdate: listen(_:))
        T.listenTeams(gamecode, onListenerUpdate: listen(_:))
    }
    
    func timeConvert(min : Int, sec : Int) -> Int {
        return (min * 60 + sec)
    }
    func listen(_ _ : [String : Any]){
    }

}


extension SettingTimeHostViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 61
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row)  minutes"
        case 1:
            return "\(row)  seconds"
        default:
            return ""
        }    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickertype == 0) {
            switch component {
            case 0:
                gameminutes = row
            case 1:
                gameseconds = row
            default:
                break
            }
        } else {
            switch component {
            case 0:
                moveminutes = row
            case 1:
                moveseconds = row
            default:
                break
            }
        }

    }
}
//extension SettingTimeHostViewController: GetHost {
//    func getHost(_ host: Host) {
//        self.host = host
//    }
//}

extension SettingTimeHostViewController: HostUpdateListener, TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
    }

    
    func updateHost(_ host: Host) {

    }
}
