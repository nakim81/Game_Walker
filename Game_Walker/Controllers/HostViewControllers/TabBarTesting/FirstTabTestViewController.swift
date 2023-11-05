//
//  FirstTabTestViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/23.
//

import Foundation
import UIKit

class FirstTabTestViewController: UIViewController {
    
    //MARK: - UI Elements
    let leaveButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftItemsSupplementBackButton = true


        configureNavBar()
    }
    
    private func configureNavBar() {
        
        // Handles Previous Navigation Stack
        let leaveButtonImage = UIImage(named: "LEAVE")
        leaveButton.setImage(leaveButtonImage, for: .normal)
        leaveButton.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        
        let leaveButtonContainer = UIView(frame: leaveButton.frame)
        leaveButtonContainer.addSubview(leaveButton)
        
        leaveButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        leaveButtonContainer.widthAnchor.constraint(equalToConstant: 45).isActive = true
        leaveButtonContainer.heightAnchor.constraint(equalToConstant: 45).isActive = true

        leaveButton.translatesAutoresizingMaskIntoConstraints = false
        leaveButton.leadingAnchor.constraint(equalTo: leaveButtonContainer.leadingAnchor, constant: 30).isActive = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leaveButtonContainer)
    }
    
    @objc private func leaveButtonTapped() {
        
    }
    
}
