//
//  HostMessageViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 3/7/23.
//

import Foundation
import UIKit

class HostMessageViewController: UIViewController {
    private let fontColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
    private var messages: [Announcement] = []
    private let cellSpacingHeight: CGFloat = 0
    
    private let messageTableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    
    private let gameCode = UserData.readGamecode("gamecode")
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var  messageLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Announcement", comment: "")
        label.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 40)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addAnnouncementBtn: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.setBackgroundImage(UIImage(named: "AddAnnouncementBtn"), for: .normal)
        button.addTarget(self, action: #selector(showPopUp), for: .touchUpInside)
        return button
    }()
    
    @objc func showPopUp(sender: UIButton) {
        showAddHostMessagePopUp(announcement: Announcement(), source: "btn")
    }
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 20)

        // enable
        button.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
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
    
    convenience init(messages: [Announcement]) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.messages = messages
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
        configureTableView()
        setUpViews()
        makeConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: .newDataNotif, object: nil)
    }
    
    @objc func refresh() {
        Task {
            try await Task.sleep(nanoseconds: 250_000_000)
            self.messages = HostRankingViewcontroller.messages
            messageTableView.reloadData()
        }
    }
    
    private func configureTableView() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
        messageTableView.backgroundColor = .clear
        messageTableView.allowsSelection = false
        messageTableView.separatorStyle = .none
        messageTableView.allowsSelection = true
        messageTableView.allowsMultipleSelection = false
        messageTableView.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
    }
    
    private func setUpViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(messageTableView)
        containerView.addSubview(addAnnouncementBtn)
        containerView.addSubview(closeButton)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTableView.translatesAutoresizingMaskIntoConstraints = false
        addAnnouncementBtn.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 210),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -210),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            messageLabel.widthAnchor.constraint(equalToConstant: 250),
            messageLabel.heightAnchor.constraint(equalToConstant: 45),
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            messageTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            messageTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            messageTableView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
            messageTableView.bottomAnchor.constraint(equalTo: addAnnouncementBtn.topAnchor, constant: -15),
            messageTableView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            addAnnouncementBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            addAnnouncementBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            addAnnouncementBtn.widthAnchor.constraint(equalTo: messageTableView.widthAnchor),
            addAnnouncementBtn.heightAnchor.constraint(equalToConstant: 40),
            NSLayoutConstraint(item: addAnnouncementBtn, attribute: .bottom, relatedBy: .equal, toItem: closeButton, attribute: .top, multiplier: 1, constant: -20),
            
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.3877),
            closeButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.12424),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}

// MARK: - TableView
extension HostMessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        let ind = indexPath.item + 1
        cell.configureTableViewCell(name: "Announcement \(ind)", read: false, role: "host")
        cell.selectionStyle = .none
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let announcement = messages[indexPath.row]
        showModifyHostMessagePopUp(announcement: announcement, index: indexPath.row, source: "table")
        messageTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, success in
            HostRankingViewcontroller.messages.remove(at: indexPath.row)
            self?.messages.remove(at: indexPath.row)
            self?.messageTableView.deleteRows(at: [indexPath], with: .automatic)
            Task { @MainActor in
                try await H.removeAnnouncement(self?.gameCode ?? "", indexPath.row)
                try await Task.sleep(nanoseconds: 200_000_000)
                NotificationCenter.default.post(name: .newDataNotif, object: nil)
            }
            success(true)
        }
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor = UIColor(red: 0.396, green: 0.246, blue: 0.454, alpha: 1)
        
        let favoriteAction = UIContextualAction(style: .normal, title: "") { [weak self] _, _, success in
            self?.messageTableView.reloadRows(at: [indexPath], with: .automatic)
            success(true)
        }
        favoriteAction.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
        return UISwipeActionsConfiguration(actions: [deleteAction, favoriteAction])
    }
}
// MARK: - AnnouncementPopUp
extension HostMessageViewController {
    func showAddHostMessagePopUp(announcement: Announcement, source: String) {
        let popUpViewController = HostAddOrModifyMessageViewController(announcement: announcement, source: source)
        showAddHostMessagePopUp(popUpViewController: popUpViewController)
    }
    
    private func showAddHostMessagePopUp(popUpViewController: HostAddOrModifyMessageViewController) {
        present(popUpViewController, animated: false, completion: nil)
    }
    
    func showModifyHostMessagePopUp(announcement: Announcement, index: Int, source: String) {
        let popUpViewController = HostAddOrModifyMessageViewController(announcement: announcement, index: index, source: source)
        showAddHostMessagePopUp(popUpViewController: popUpViewController)
    }
    
    private func showModifyHostMessagePopUp(popUpViewController: HostAddOrModifyMessageViewController) {
        present(popUpViewController, animated: false, completion: nil)
    }
}
