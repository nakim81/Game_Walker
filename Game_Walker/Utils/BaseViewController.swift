//
//  BaseViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 7/11/22.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()        
    }
    
    func configureNavBar() {
        let backButtonImage = UIImage(named: "BackIcon")?.withRenderingMode(.alwaysTemplate)

        // Create a custom bar button item with the image
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(onBackPressed))

        // Customize the appearance of the back button (optional)
        backButton.tintColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1)

        // Assign the custom back button to the navigationItem
        navigationItem.leftBarButtonItem = backButton
        
        let gameCode = UserData.readGamecode("gamecode") ?? ""
        
        let gameCodeLabel: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: 127, height: 42)
            let attributedText = NSMutableAttributedString()
            let gameCodeAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.black
            ]
            let gameCodeAttributedString = NSAttributedString(string: "Game Code\n", attributes: gameCodeAttributes)
            attributedText.append(gameCodeAttributedString)
            let numberAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Dosis-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20),
                .foregroundColor: UIColor.black
            ]
            let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
            attributedText.append(numberAttributedString)
            label.backgroundColor = .white
            label.attributedText = attributedText
            label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
            label.numberOfLines = 0
            label.adjustsFontForContentSizeCategory = false
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        navigationItem.titleView = gameCodeLabel
    }
    
    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func alert2(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) {value in
            self.performSegue(withIdentifier: "ManageGameSegue", sender: (Any).self)
        })
        present(alert, animated: true)
    }
    
    func addLetterSpacing(to label: UILabel, spacing: CGFloat) {
        
        let labelText = NSMutableAttributedString(string: label.text ?? "")

        labelText.addAttribute(NSAttributedString.Key.kern,
                                    value: spacing,
                                    range: NSRange(location: 0, length: labelText.length))

        label.attributedText = labelText
    }
}
