//
//  EndGameViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 4/19/23.
//

import Foundation
import UIKit

class EndGameViewController: UIViewController {
    
    private let fontColor: UIColor = UIColor(red: 0.98, green: 0.204, blue: 0, alpha: 1)
    private var gameCode = ""
    weak var delegate: ModalViewControllerDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = fontColor
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var  warningLbl: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("HEADS UP!", comment: "")
        view.backgroundColor = .clear
        view.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 40))
        view.textColor = .white
        view.textAlignment = .center
        view.numberOfLines = 1
        return view
    }()
    
    private lazy var warningTextLbl: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 24))
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var noButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: fontSize(size: 20))
        // enable
        button.setTitle(NSLocalizedString("NO", comment: ""), for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)

        // disable
        button.setTitleColor(fontColor, for: .disabled)
        button.setBackgroundImage(UIColor.white.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 6
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        return button
    }()
    
    private lazy var yesButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: fontSize(size: 20))
        // enable
        button.setTitle(NSLocalizedString("YES", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setBackgroundImage(UIColor.clear.image(), for: .normal)

        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 4.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(endGame), for: .touchUpInside)
        return button
    }()
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func endGame() {
        //TODO- End Game and post it to the firebase and move to the awardViewController
        Task {@MainActor in
            do {
                try await H.endGame(self.gameCode)
                dismiss(animated: true, completion: nil)
                delegate?.modalViewControllerDidRequestPush()
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name("stop"), object: nil, userInfo: ["note" : ""])
        }
        
    }
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 17.0
        view.distribution = .fillEqually
        return view
    }()
    
    convenience init(announcement: String, source: String, gamecode: String) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.modalPresentationStyle = .overFullScreen
        self.gameCode = gamecode
        self.warningTextLbl.text = announcement
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        makeConstraints()
    }
    
    private func setUpViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(warningLbl)
        containerView.addSubview(warningTextLbl)
        containerView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(yesButton)
        buttonStackView.addArrangedSubview(noButton)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        warningLbl.translatesAutoresizingMaskIntoConstraints = false
        warningTextLbl.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4064039409),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8666666667),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            warningLbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            warningLbl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            warningLbl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            warningLbl.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.1303030303),
            
            warningTextLbl.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor),
            warningTextLbl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            warningTextLbl.topAnchor.constraint(equalTo: warningLbl.bottomAnchor),
            warningTextLbl.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -15),

            buttonStackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            buttonStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.13)
        ])
    }
}
