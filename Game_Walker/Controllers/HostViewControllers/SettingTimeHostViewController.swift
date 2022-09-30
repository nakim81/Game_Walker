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
    var pickertype = 0
    
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
        
        gametimePickerView = UIView(frame: CGRect(x:0, y: view.frame.height + 260, width: view.frame.width, height: 260))
        view.addSubview(gametimePickerView)
        gametimePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gametimePickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            gametimePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 260),
            gametimePickerView.heightAnchor.constraint(equalToConstant: 260)
        ])
        
        gametimePickerView.backgroundColor = .white
        
        gametimePicker = UIPickerView(frame: CGRect(x: 0, y:0, width: view.frame.width, height: 260))
        gametimePickerView.addSubview(gametimePicker)
        
        gametimePicker.isUserInteractionEnabled = true
        gametimePickerView.addSubview(gametimePicker)
        
        gametimePicker.delegate = self
        gametimePicker.dataSource = self
        
        
        
    }
    
    @IBAction func gametimePressed(_ sender: UIButton) {
        pickerAppear()
    }
    
    
    @objc func applyDone() {
        view.endEditing(true)
    }
    
    func pickerAppear() {
        if (pickertype == 0) {
            UIView.animate(withDuration: 0.3, animations: {
                self.gametimePickerView.frame = CGRect(x:0, y: self.view.bounds.height - self.gametimePickerView.bounds.size.height, width: self.gametimePickerView.bounds.size.width, height: self.gametimePickerView.bounds.size.height)
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.movetimePickerView.frame = CGRect(x:0, y: self.view.bounds.height - self.movetimePickerView.bounds.size.height, width: self.movetimePickerView.bounds.size.width, height: self.movetimePickerView.bounds.size.height)
            })
        }
    }
    
    func pickerDisappear() {
        if (pickertype == 0) {
            UIView.animate(withDuration: 0.3, animations:{
                self.gametimePicker.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.gametimePickerView.bounds.size.width, height: self.gametimePickerView.bounds.size.height)
            })
        } else {
            UIView.animate(withDuration: 0.3, animations:{
                self.movetimePicker.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.movetimePickerView.bounds.size.width, height: self.movetimePickerView.bounds.size.height)})
        }
    }

}


extension SettingTimeHostViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
}
