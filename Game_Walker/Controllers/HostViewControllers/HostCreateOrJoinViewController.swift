//
//  HostCreateOrJoinViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/22/22.
//

import UIKit

class HostCreateOrJoinViewController: BaseViewController {
    @IBOutlet weak var resumeButton: UIButton!
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureNavItem()
        NotificationCenter.default.addObserver(self, selector: #selector(performStandardModeSegue), name: Notification.Name("StandardMode"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(performPointsOnlySegue), name: Notification.Name("PointsOnly"), object: nil)
        
    }
    
    @objc private func performStandardModeSegue() {
        performSegue(withIdentifier: "CreateStandardGameSegue", sender: self)
    }
    
    @objc private func performPointsOnlySegue() {
        performSegue(withIdentifier: "CreatePointsOnlySegue", sender: self)
    }
    
    private func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let backButtonImage = UIImage(named: "BackIcon")?.withRenderingMode(.alwaysTemplate)
        let newBackButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(back))
        newBackButton.tintColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1)
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings-icon"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        navigationItem.rightBarButtonItem = settingsButton

    }
    
    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToMainVC", sender: self)
    }
    
    @objc func settingsButtonTapped() {
        
    }
        
    @IBAction func resumeButtonPressed(_ sender: UIButton) {
        
            if UserData.readGamecode("gamecode") != nil {
//                print("host resume game segue")
//                performSegue(withIdentifier: "ResumeGameToCodeSegue", sender: self)
            } else {
                alert(title: "", message: "No game exists")
        }
    }

    
    @IBAction func createButtonPressed(_ sender: UIButton) {

    }
    
    
    
}

