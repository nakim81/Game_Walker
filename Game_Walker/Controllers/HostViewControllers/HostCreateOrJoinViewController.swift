//
//  HostCreateOrJoinViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/22/22.
//

import UIKit

class HostCreateOrJoinViewController: UIViewController {
    @IBOutlet weak var resumeButton: UIButton!
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavItem()
        configureButtonVisuals()

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
        configureSettingBtn()
    }

    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToMainVC", sender: self)
    }
        
    @IBAction func resumeButtonPressed(_ sender: UIButton) {
            if UserData.readGamecode("gamecode") != nil {

            } else {
                alert(title: NSLocalizedString("No game exists.", comment: ""), message: "")
        }
    }

    
    @IBAction func createGameButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showChooseModalSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChooseModalSegue",
           let chooseStyleModalVC = segue.destination as? ChooseStyleModalViewController {
            chooseStyleModalVC.delegate = self
        }
    }

    private func configureButtonVisuals() {
        createButton.layer.cornerRadius = 10.0
        resumeButton.layer.cornerRadius = 10.0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
}

extension HostCreateOrJoinViewController: ChooseStyleModalDelegate {
    func didSelectStandardMode() {
        performStandardModeSegue()
    }
    
    func didSelectPointsOnlyMode() {
        performPointsOnlySegue()
    }
    

}

