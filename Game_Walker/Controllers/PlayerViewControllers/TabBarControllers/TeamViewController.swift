//
//  PlayerFrame4_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class TeamViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var teamNumLbl: UILabel!
    @IBOutlet weak var teamNameLbl: UILabel!
    
    static var localMessages: [Announcement] = []
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    private var team: Team?
    private var currentPlayer = UserData.readPlayer("player") ?? Player()
    private var gameCode = UserData.readGamecode("gamecode") ?? ""
    private var teamName = UserData.readTeam("team")?.name ?? ""
    private let refreshController : UIRefreshControl = UIRefreshControl()
    
    private var timer = Timer()
    static var unread: Bool = false
    private var diff: Int?
    
    private let audioPlayerManager = AudioPlayerManager()
    
    static let notificationName1 = Notification.Name("readNotification")
    static let notificationName2 = Notification.Name("announceNoti")
    
    private lazy var gameCodeLabel: UILabel = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHostListener()
        configureTableView()
        configureLabel()
        settingButton.tintColor = UIColor(red: 0.267, green: 0.659, blue: 0.906, alpha: 1)
        // timer checks if all the announcements are read or not
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            // true if some announcements are unread, false if all read
            let unread = strongSelf.checkUnreadAnnouncements(announcements: TeamViewController.localMessages)
            TeamViewController.unread = unread
            if unread{
                NotificationCenter.default.post(name: TeamViewController.notificationName1, object: nil, userInfo: ["unread":unread])
                strongSelf.announcementButton.setImage(strongSelf.unreadSome, for: .normal)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
            } else {
                NotificationCenter.default.post(name: TeamViewController.notificationName1, object: nil, userInfo: ["unread":unread])
                strongSelf.announcementButton.setImage(strongSelf.readAll, for: .normal)
            }
        }
    }
    
    private func addHostListener(){
        H.delegates.append(self)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
    }
    
    private func configureLabel(){
        let team = UserData.readTeam("team") ?? Team()
        
        teamNumLbl.text = "TEAM \(String(describing: team.number))"
        teamNameLbl.text = team.name
        
        view.addSubview(gameCodeLabel)
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (self.navigationController?.navigationBar.frame.minY)!),
            gameCodeLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.05),
            gameCodeLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3)
        ])
    }
    
    private func configureTableView() {
        table.delegate = self
        table.dataSource = self
        table.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.identifier)
        table.backgroundColor = .clear
        table.allowsSelection = false
        table.separatorStyle = .none
        table.refreshControl = refreshController
        settingRefreshControl()
        Task { @MainActor in
            do {
                self.team = try await T.getTeam(gameCode, teamName)
                table.reloadData()
            } catch {
                alert(title: "Connection Error", message: "Swipe down your screen to see your team members!")
            }
        }
    }
    
    @IBAction func leaveButtonPressed(_ sender: UIButton) {
        self.alert2(title: "", message: "Do you really want to leave your team?", sender: sender)
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showMessagePopUp(messages: TeamViewController.localMessages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    private func alert2(title: String, message: String, sender: UIButton) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Leave", style: .destructive, handler: { [self]action in
            Task { @MainActor in
                do {
                    try await T.leaveTeam(self.gameCode, self.teamName, self.currentPlayer)
                    if let team = self.team {
                        if (team.players.count == 1) {
                            T.removeTeam(gameCode, team)
                        }
                    }
                    UserData.clearMyTeam("team")
                    self.performSegue(withIdentifier: "returnToCorJ", sender: sender)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
            }
        })
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Stay", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
        refreshController.attributedTitle = NSAttributedString(string: "reloading,,,", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1) , NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
    
    @objc func refreshFunction() {
        Task { @MainActor in
            do {
                self.team = try await T.getTeam(gameCode, teamName)
                refreshController.endRefreshing()
                table.reloadData()
            } catch {
                alert(title: "Connection Error", message: "Swipe down your screen to see your team members!")
            }
        }
    }
    
    func listen(_ _ : [String : Any]){
    }
}
// MARK: - TableView
extension TeamViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: TeamTableViewCell.identifier, for: indexPath) as! TeamTableViewCell
        cell.configureTeamTableViewCell(name: team!.players[indexPath.row].name)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let team = team else {
            return 0
        }
        return team.players.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            // Return the height of the cell plus the spacing.
            return 65
        }
}

// MARK: - TeamProtocol
extension TeamViewController: HostUpdateListener {
    func updateHost(_ host: Host) {
        var hostAnnouncements = Array(host.announcements)
        // if some announcements were deleted from the server
        if TeamViewController.localMessages.count > hostAnnouncements.count {
            removeAnnouncementsNotInHost(from: &TeamViewController.localMessages, targetArray: hostAnnouncements)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil, userInfo: nil)
        } else {
            // compare server announcements and local announcements
            for announcement in hostAnnouncements {
                let ids: [String] = TeamViewController.localMessages.map({ $0.uuid })
                // new announcements
                if !ids.contains(announcement.uuid) {
                    TeamViewController.localMessages.append(announcement)
                    self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                    NotificationCenter.default.post(name: TeamViewController.notificationName2, object: nil, userInfo: nil)
                } else {
                    // modified announcements
                    if let localIndex = TeamViewController.localMessages.firstIndex(where: {$0.uuid == announcement.uuid}) {
                        if TeamViewController.localMessages[localIndex].content != announcement.content {
                            TeamViewController.localMessages[localIndex].content = announcement.content
                            TeamViewController.localMessages[localIndex].readStatus = false
                            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                            NotificationCenter.default.post(name: TeamViewController.notificationName2, object: nil, userInfo: nil)
                        }
                    }
                }
                
            }
        }
    }
}



