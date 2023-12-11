//
//  RefereeAnnouncementController.swift
//  Game_Walker
//
//  Created by 김현식 on 2/13/23.
//

import Foundation
import UIKit

class RefereeAnnouncementViewController: UIViewController {
    private var announcement: Announcement?
    private let fontColor: UIColor = UIColor(cgColor: .init(red: 0.333, green: 0.745, blue: 0.459, alpha: 1))
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: .init(red: 0.333, green: 0.745, blue: 0.459, alpha: 1))
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var announcementScrollView: UIScrollView = {
        let view = UIScrollView()
        view.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var announcementTextLabel: UILabel = {
        let label = UILabel()
        label.text = self.announcement?.content
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont(name: "Dosis-Regular", size: 18)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "GemunuLibre-Bold", size: 20)
        
        // enable
        button.setTitle("Close", for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)
        
        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)
        
        // layer
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        
        return button
    }()
    
    public func addActionToButton(title: String? = nil, titleColor: UIColor, backgroundColor: UIColor = .white, completion: (() -> Void)? = nil) {
        self.closeButton.addAction(for: .touchUpInside) { _ in
            completion?()
        }
    }
    
    convenience init(announcement: Announcement?) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.announcement = announcement
        self.modalPresentationStyle = .overFullScreen
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
        containerView.addSubview(announcementScrollView)
        announcementScrollView.addSubview(announcementTextLabel)
        containerView.addSubview(closeButton)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        announcementScrollView.translatesAutoresizingMaskIntoConstraints = false
        announcementTextLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 210),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -210),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            announcementScrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            announcementScrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            announcementScrollView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            announcementScrollView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),
            announcementScrollView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            announcementTextLabel.topAnchor.constraint(equalTo: announcementScrollView.topAnchor, constant: 10),
            announcementTextLabel.bottomAnchor.constraint(equalTo: announcementScrollView.bottomAnchor, constant: 10),
            announcementTextLabel.centerXAnchor.constraint(equalTo: announcementScrollView.centerXAnchor, constant: 10),
            announcementTextLabel.widthAnchor.constraint(equalTo: announcementScrollView.widthAnchor, constant: 10),

            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.3877),
            closeButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.12424),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}

