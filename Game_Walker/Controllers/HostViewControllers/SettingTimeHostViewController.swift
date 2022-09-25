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
    @IBOutlet weak var roundsLabel: UILabel!
    
    var minutes: Int = 0
    var seconds: Int = 0
    
    //UIPickerView inside of UIView container
    var gametimePickerView: UIView!
    var gametimePicker: UIPickerView!
    var movetimePickerView: UIView!
    var movetimePicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: 30))
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self,  action: #selector(self.applyDone))
        
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        gametimePickerView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    @objc func applyDone() {
        view.endEditing(true)
    }
    

}
