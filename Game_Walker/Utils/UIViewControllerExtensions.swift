//
//  UIViewController+Extensions.swift
//  Game_Walker
//
//  Created by Noah Kim on 7/11/22.
//

import UIKit
// MARK: - GameInfoPopUps
extension UIViewController {
    func showGameInfoPopUp(gameName: String? = nil, gameLocation: String? = nil, gamePoitns: String? = nil, refereeName: String? = nil, gameRule: String? = nil, _ actionTitle: String = NSLocalizedString("Close", comment: ""), _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = GameInfoViewController(gameName: gameName ?? "", gameLocation: gameLocation ?? "", gamePoints: gamePoitns ?? "", refereeName: refereeName ?? "", gameRule: gameRule ?? "")
        showGameInfoPopUp(popUpViewController: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showGameInfoPopUp(popUpViewController: GameInfoViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewController.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
    
    func showRefereeGameInfoPopUp(gameName: String? = nil, gameLocation: String? = nil, gamePoitns: String? = nil, gameRule: String? = nil, _ actionTitle: String = NSLocalizedString("Close", comment: ""), _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = RefereeGameInfoViewcontroller(gameName: gameName ?? "", gameLocation: gameLocation ?? "", gamePoints: gamePoitns ?? "", gameRule: gameRule ?? "")
        showRefereeGameInfoPopUp(popUpViewController: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showRefereeGameInfoPopUp(popUpViewController: RefereeGameInfoViewcontroller, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewController.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
}
// MARK: - PlayerMessagePopUps
extension UIViewController {
    func showMessagePopUp(messages: [Announcement], _ actionTitle: String = NSLocalizedString("Close", comment: ""), _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = MessageViewController(messages: messages)
        showMessagePopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showMessagePopUp(popUpViewcontroller: MessageViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
    
    func showAnnouncementPopUp(announcement: Announcement, _ actionTitle: String = NSLocalizedString("Close", comment: ""), _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = AnnouncementViewController(announcement: announcement)
        showAnnouncementPopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showAnnouncementPopUp(popUpViewcontroller: AnnouncementViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
}
// MARK: - RefereeMessagePopUps
extension UIViewController {
    func showRefereeMessagePopUp(messages: [Announcement], _ actionTitle: String = NSLocalizedString("Close", comment: ""), _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = RefereeMessageViewController(messages: messages)
        showRefereeMessagePopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showRefereeMessagePopUp(popUpViewcontroller: RefereeMessageViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
    
    func showRefereeAnnouncementPopUp(announcement: Announcement, _ actionTitle: String = NSLocalizedString("Close", comment: ""), _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = RefereeAnnouncementViewController(announcement: announcement)
        showRefereeAnnouncementPopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showRefereeAnnouncementPopUp(popUpViewcontroller: RefereeAnnouncementViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
}

// MARK: - InfoPopUp
extension UIViewController {
    func showInfoPopUp(_ actionTitle: String = NSLocalizedString("Close", comment: ""), _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = InfoViewController(select: true)
        showInfoPopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showInfoPopUp(popUpViewcontroller: InfoViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
}
// MARK: - HostMessagePopUps
extension UIViewController {
    func showHostMessagePopUp(messages: [Announcement], _ actionTitle: String = NSLocalizedString("Close", comment: ""), _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = HostMessageViewController(messages: messages)
        showHostMessagePopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showHostMessagePopUp(popUpViewcontroller: HostMessageViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
}
// MARK: - AwardPopUps
extension UIViewController {
    func showAwardPopUp( _ from: String) {
        let awardViewController = AwardViewController()
        awardViewController.from = from
        self.navigationController?.pushViewController(awardViewController, animated: true)
    }
}
// MARK: - WarningPopUp
extension UIViewController {
    func showEndGamePopUp(announcement: String, source: String, gamecode: String) {
        let popUpViewController = EndGameViewController(announcement: announcement, source: source, gamecode: gamecode)
        showEndGamePopUp(popUpViewController: popUpViewController)
    }
    
    private func showEndGamePopUp(popUpViewController: EndGameViewController) {
        present(popUpViewController, animated: false, completion: nil)
    }
    
    func showStartGamePopUp(announcement: String, source: String, gamecode: String) {
        let popUpViewController = StartGameViewController(announcement: announcement, source: source, gamecode: gamecode)
        showStartGamePopUp(popUpViewController: popUpViewController)
    }
    
    private func showStartGamePopUp(popUpViewController: StartGameViewController) {
        present(popUpViewController, animated: true)
    }
}
// MARK: - Alert
extension UIViewController {
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss!", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    func gamecodeAlert(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Gamecode Error!", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss!", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    func serverAlert(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Server Error!", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss!", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func teamNumberAlert(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Team Number Error!", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss!", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
// MARK: - textField
extension UITextField {
    func setPadding(left: CGFloat, right: CGFloat? = nil) {
        setLeftPadding(left)
        if let rightPadding = right {
            setRightPadding(rightPadding)
        }
    }

    private func setLeftPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    private func setRightPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
}
// MARK: - Date Formatter
extension UIViewController {
    func getCurrentDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current // Use the current time zone
        
        let currentDateTime = Date()
        let dateString = dateFormatter.string(from: currentDateTime)
        
        return dateString
    }
}
//MARK: - Array Convert
extension UIViewController {
    func convert2DArrayTo1D(_ inputArray: [[Int]]) -> [Int] {
        let rows = inputArray.count
        let columns = inputArray.isEmpty ? 0 : inputArray[0].count
        var resultArray: [Int] = [rows, columns]
        for subArray in inputArray {
            resultArray += subArray
        }
        return resultArray
    }
    
    func convert1DArrayTo2D(_ inputArray: [Int]) -> [[Int]] {
        guard inputArray.count >= 2 else {
            fatalError("Input array is too short to determine dimensions.")
        }
        let rows = inputArray[0]
        let columns = inputArray[1]
        guard inputArray.count == 2 + (rows * columns) else {
            fatalError("Input array size does not match the specified dimensions.")
        }
        var resultArray: [[Int]] = []
        var currentIndex = 2 // Skip the first two elements
        
        for _ in 0..<rows {
            var subArray: [Int] = []
            for _ in 0..<columns {
                subArray.append(inputArray[currentIndex])
                currentIndex += 1
            }
            resultArray.append(subArray)
        }
        return resultArray
    }
}
// MARK: - methods for announcements
extension UIViewController {
    func removeAnnouncementsNotInHost(from sourceArray: inout [Announcement], targetArray: [Announcement]) {
        sourceArray = sourceArray.filter { sourceAnnouncement in
            targetArray.contains { targetAnnouncement in
                sourceAnnouncement.uuid == targetAnnouncement.uuid
            }
        }
    }
    
    func checkUnreadAnnouncements(announcements: [Announcement]) -> Bool {
        let unreadAnnouncements = announcements.filter { $0.readStatus == false }
        
        return !unreadAnnouncements.isEmpty
    }
}
// MARK: - Nav Bar
extension UIViewController {
    
    func configureTitleLabel() {
        let gameCode = UserData.readGamecode("gamecode") ?? ""
        
        let gameCodeLabel: UILabel = {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: 127, height: 42)
            let attributedText = NSMutableAttributedString()
            let gameCodeAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.black
            ]
            let gameCodeAttributedString = NSAttributedString(string: NSLocalizedString("Game Code", comment: "") + "\n", attributes: gameCodeAttributes)
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
    
    func configureSettingBtn() {
        let settingImage = UIImage(named: "settingIcon")
        let settingBtn = UIButton()
        settingBtn.setImage(settingImage, for: .normal)
        settingBtn.addTarget(self, action: #selector(settingApp), for: .touchUpInside)
        let setting = UIBarButtonItem(customView: settingBtn)
        
        self.navigationItem.rightBarButtonItems = [setting]
    }
    
    func createSpacer() -> UIBarButtonItem {
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 5
        return spacer
    }
    
    func configureRightBarButtonItems() {
        let settingImage = UIImage(named: "settingIcon")
        let settingBtn = UIButton()
        settingBtn.setImage(settingImage, for: .normal)
        settingBtn.addTarget(self, action: #selector(settingApp), for: .touchUpInside)
        let setting = UIBarButtonItem(customView: settingBtn)
        
        let spacer = createSpacer()
        
        let infoImage = UIImage(named: "infoIcon")
        let infoBtn = UIButton()
        infoBtn.setImage(infoImage, for: .normal)
        infoBtn.addTarget(self, action: #selector(infoAction), for: .touchUpInside)
        let info = UIBarButtonItem(customView: infoBtn)

        let announceImage = UIImage(named: "messageIcon")
        let announceBtn = UIButton()
        announceBtn.setImage(announceImage, for: .normal)
        announceBtn.addTarget(self, action: #selector(announceAction), for: .touchUpInside)
        announceBtn.tag = 120
        let announce = UIBarButtonItem(customView: announceBtn)
        
        self.navigationItem.rightBarButtonItems = [setting, spacer, announce, spacer, info]
    }
    
    func configureBackButton() {
        let backButtonImage = UIImage(named: "BackIcon")?.withRenderingMode(.alwaysTemplate)

        // Create a custom bar button item with the image
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(onBackPressed))

        // Customize the appearance of the back button (optional)
        backButton.tintColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1)

        // Assign the custom back button to the navigationItem
        navigationItem.leftBarButtonItem = backButton
    }
    
    func configureNavigationBar() {
        configureRightBarButtonItems()
        configureTitleLabel()
    }
    
    func configureSimpleNavBar() {
        configureBackButton()
        configureSettingBtn()
        configureTitleLabel()
    }
    
    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func infoAction() {
    }
    
    @objc func settingApp() {
        let settingsVC = SettingsViewController()
        settingsVC.modalPresentationStyle = .overFullScreen
        present(settingsVC, animated: true, completion: nil)
        
    }
    
    @objc func announceAction() {
    }
}
// MARK: - Color
extension UIColor {
    convenience init?(hex: Int) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
// MARK: - etc
extension UIViewController {
    func fontSize(size: CGFloat) -> CGFloat {
        let size_formatter = size/390
        let result = UIScreen.main.bounds.size.width * size_formatter
        return result
    }
    
    /// find the number of pvp games
    func findNumberOfPVP(_ stationList: [Station]) -> Int {
        var pvp = 0
        for station in stationList {
            if station.pvp {
                pvp += 1
            }
        }
        return pvp
    }
    
    func alert2(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss!", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm!", comment: ""), style: .default) {value in
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
