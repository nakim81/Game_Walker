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
        T.delegates.append(self)
        configureNavItem()
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
    
    func listen(_ _ : [String : Any]){
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
        
            let gc = String(Int.random(in: 100000 ... 999999))
            let host = Host(gamecode: gc)
            Task { @MainActor in
                do {
                try await H.createGame(gc, host)
                } catch (let e) {
                    print("error : ", e)
                }
            }
            UserData.writeGamecode(gc, "gamecode")
            T.listenTeams(gc, onListenerUpdate: listen(_:))
//            print("host create game segue")
//            performSegue(withIdentifier: "CreateGameToStationsSegue", sender: self)
    }
    
    
    
}
// MARK: - TeamListner
extension HostCreateOrJoinViewController: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        
    }
}
