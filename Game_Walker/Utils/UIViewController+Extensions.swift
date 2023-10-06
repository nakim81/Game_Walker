//
//  UIViewController+Extensions.swift
//  Game_Walker
//
//  Created by Noah Kim on 7/11/22.
//

import UIKit
// MARK: - GameInfoPopUps
extension UIViewController {
    func showGameInfoPopUp(gameName: String? = nil, gameLocation: String? = nil, gamePoitns: String? = nil, refereeName: String? = nil, gameRule: String? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = GameInfoViewController(gameName: gameName ?? "", gameLocation: gameLocation ?? "", gamePoints: gamePoitns ?? "", refereeName: refereeName ?? "", gameRule: gameRule ?? "")
        showGameInfoPopUp(popUpViewController: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showGameInfoPopUp(popUpViewController: GameInfoViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewController.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
    
    func showRefereeGameInfoPopUp(gameName: String? = nil, gameLocation: String? = nil, gamePoitns: String? = nil, gameRule: String? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
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
    func showMessagePopUp(messages: [Announcement], _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = MessageViewController(messages: messages)
        showMessagePopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showMessagePopUp(popUpViewcontroller: MessageViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
    
    func showAnnouncementPopUp(announcement: Announcement, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
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
    func showRefereeMessagePopUp(messages: [Announcement], _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = RefereeMessageViewController(messages: messages)
        showRefereeMessagePopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showRefereeMessagePopUp(popUpViewcontroller: RefereeMessageViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
    
    func showRefereeAnnouncementPopUp(announcement: Announcement, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
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
    func showInfoPopUp(_ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
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
    func showHostMessagePopUp(messages: [Announcement], _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
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
    func showAwardPopUp() {
        let awardViewController = AwardViewController()
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
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    func gamecodeAlert(_ message: String) {
        let alert = UIAlertController(title: "Gamecode Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    func serverAlert(_ message: String) {
        let alert = UIAlertController(title: "Server Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
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
