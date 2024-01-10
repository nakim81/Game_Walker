//
//  GivePointsController.swift
//  Game_Walker
//
//  Created by 김현식 on 10/8/22.
//

import Foundation
import UIKit

class GivePointsController: UIViewController {
    var currentPoints: Int
    let gameCode: String
    let team: Team
    
    init(team: Team, gameCode: String) {
        self.team = team
        self.currentPoints = team.points
        self.gameCode = gameCode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        addSubViews()
        addConstraints()
        super.viewDidLoad()
    }
    
    //MARK: - UI elements
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        return view
    }()
    
    private lazy var givePointsLabel: UILabel = {
        var view = UILabel()
        view.text = NSLocalizedString("Give Points", comment: "")
        view.textColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        view.font = UIFont(name: "GemunuLibre-SemiBold", size: fontSize(size: 45))
        view.textAlignment = .center
        return view
    }()
    
    private lazy var stepper: GMStepper = {
        var view = GMStepper()
        view.frame = CGRect()
        view.buttonsBackgroundColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1)
        view.buttonsFont = UIFont(name: "Dosis-Regular", size: fontSize(size: 80)) ?? UIFont(name: "AvenirNext-Bold", size: 20.0)!
        view.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1)
        view.labelBackgroundColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1)
        view.labelFont = UIFont(name: "Dosis-Bold", size: fontSize(size: 80)) ?? UIFont(name: "AvenirNext-Bold", size: 25.0)!
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        var button = UIButton()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "icon _close_"), for: .normal)
        button.addTarget(self, action: #selector(popupClosed), for: .touchUpInside)
        return button
    }()
    
    private lazy var editButton: UIButton = {
        var button = UIButton()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "edit_green"), for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("CONFIRM", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont(name: "GemunuLibre-Bold", size: 20)
        button.setTitleColor(UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor
        button.layer.cornerRadius = 10.0
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped() {
        Task { @MainActor in
            do {
                try await T.givePoints(gameCode, team.name, Int(stepper.value))
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func popupClosed() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func editButtonTapped(_ sender: UITapGestureRecognizer) {
        showNumberInputPopup()
    }

    func showNumberInputPopup() {
        let alertController = UIAlertController(title: NSLocalizedString("Enter a number", comment: ""), message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Type the number", comment: "")
            textField.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self, weak alertController] _ in
            guard let textField = alertController?.textFields?.first, let enteredNumber = textField.text else { return }
            self?.stepper.minimumValue = -999
            self?.stepper.label.text = enteredNumber
            if Double(enteredNumber)! > 999 {
                self?.stepper.value = 999
            }
            else if Double(enteredNumber)! < -999 {
                self?.stepper.value = -999
            }
            else {
                self?.stepper.value = Double(enteredNumber)!
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        givePointsLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4),
            containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.473),
            containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            givePointsLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.620),
            givePointsLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.13),
            givePointsLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            givePointsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25/812 * UIScreen.main.bounds.size.height),
            
            closeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.125),
            closeButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.125),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),

            stepper.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            stepper.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            stepper.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.35),
            stepper.topAnchor.constraint(equalTo: givePointsLabel.bottomAnchor, constant: 20/812 * UIScreen.main.bounds.size.height),
            
            editButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.0861),
            editButton.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.0861),
            editButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            editButton.topAnchor.constraint(equalTo: stepper.bottomAnchor, constant: 15/812 * UIScreen.main.bounds.size.height),
            
            confirmButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.38),
            confirmButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.11),
            confirmButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIScreen.main.bounds.size.height * 20/812)
        ])
    }
    
    func addSubViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(givePointsLabel)
        containerView.addSubview(editButton)
        containerView.addSubview(closeButton)
        containerView.addSubview(stepper)
        containerView.addSubview(confirmButton)
    }
}

//MARK: - GMStepper
@IBDesignable public class GMStepper: UIControl {

    /// Current value of the stepper. Defaults to 0.
    @objc @IBInspectable public var value: Double = 0 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))

            label.text = formattedValue

            if oldValue != value {
                sendActions(for: .valueChanged)
            }
        }
    }
    
    private var formattedValue: String? {
        let isInteger = Decimal(value).exponent >= 0
        
        // If we have items, we will display them as steps
        if isInteger && stepValue == 1.0 && items.count > 0 {
            return items[Int(value)]
        }
        else {
            return formatter.string(from: NSNumber(value: value))
        }
    }


    /// Minimum value. Must be less than maximumValue.
    @objc @IBInspectable public var minimumValue: Double = 0 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))
        }
    }

    /// Maximum value. Must be more than minimumValue.
    @objc @IBInspectable public var maximumValue: Double = 999 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))
        }
    }

    /// Step/Increment value as in UIStepper. Defaults to 1.
    @objc @IBInspectable public var stepValue: Double = 1 {
        didSet {
            setupNumberFormatter()
        }
    }

    /// The same as UIStepper's autorepeat. If true, holding on the buttons or keeping the pan gesture alters the value repeatedly. Defaults to true.
    @objc @IBInspectable public var autorepeat: Bool = true

    /// If the value is integer, it is shown without floating point.
    @objc @IBInspectable public var showIntegerIfDoubleIsInteger: Bool = true {
        didSet {
            setupNumberFormatter()
        }
    }

    /// Text on the left button. Be sure that it fits in the button. Defaults to "−".
    @objc @IBInspectable public var leftButtonText: String = "−" {
        didSet {
            leftButton.setTitle(leftButtonText, for: .normal)
        }
    }

    /// Text on the right button. Be sure that it fits in the button. Defaults to "+".
    @objc @IBInspectable public var rightButtonText: String = "+" {
        didSet {
            rightButton.setTitle(rightButtonText, for: .normal)
        }
    }

    /// Text color of the buttons. Defaults to white.
    @objc @IBInspectable public var buttonsTextColor: UIColor = UIColor.white {
        didSet {
            for button in [leftButton, rightButton] {
                button.setTitleColor(buttonsTextColor, for: .normal)
            }
        }
    }

    /// Background color of the buttons. Defaults to dark blue.
    @objc @IBInspectable public var buttonsBackgroundColor: UIColor = UIColor(red:0.21, green:0.5, blue:0.74, alpha:1) {
        didSet {
            for button in [leftButton, rightButton] {
                button.backgroundColor = buttonsBackgroundColor
            }
            backgroundColor = buttonsBackgroundColor
        }
    }

    /// Font of the buttons. Defaults to AvenirNext-Bold, 20.0 points in size.
    @objc public var buttonsFont = UIFont(name: "AvenirNext-Bold", size: 20)! {
        didSet {
            for button in [leftButton, rightButton] {
                button.titleLabel?.font = buttonsFont
            }
        }
    }

    /// Text color of the middle label. Defaults to white.
    @objc @IBInspectable public var labelTextColor: UIColor = UIColor.white {
        didSet {
            label.textColor = labelTextColor
        }
    }

    /// Text color of the middle label. Defaults to lighter blue.
    @objc @IBInspectable public var labelBackgroundColor: UIColor = UIColor(red:0.26, green:0.6, blue:0.87, alpha:1) {
        didSet {
            label.backgroundColor = labelBackgroundColor
        }
    }

    /// Font of the middle label. Defaults to AvenirNext-Bold, 25.0 points in size.
    @objc public var labelFont = UIFont(name: "AvenirNext-Bold", size: 25.0)! {
        didSet {
            label.font = labelFont
        }
    }
       /// Corner radius of the middle label. Defaults to 0.
    @objc @IBInspectable public var labelCornerRadius: CGFloat = 0 {
        didSet {
            label.layer.cornerRadius = labelCornerRadius
        
            }
    }

    /// Corner radius of the stepper's layer. Defaults to 4.0.
    @objc @IBInspectable public var cornerRadius: CGFloat = 4.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
    }
    
    /// Border width of the stepper and middle label's layer. Defaults to 0.0.
    @objc @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
            label.layer.borderWidth = borderWidth
        }
    }
    
    /// Color of the border of the stepper and middle label's layer. Defaults to clear color.
    @objc @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            label.layer.borderColor = borderColor.cgColor
        }
    }

    /// Percentage of the middle label's width. Must be between 0 and 1. Defaults to 0.5. Be sure that it is wide enough to show the value.
    @objc @IBInspectable public var labelWidthWeight: CGFloat = 0.7 {
        didSet {
            labelWidthWeight = min(1, max(0, labelWidthWeight))
            setNeedsLayout()
        }
    }

    /// Color of the flashing animation on the buttons in case the value hit the limit.
    @objc @IBInspectable public var limitHitAnimationColor: UIColor = UIColor(red:0.26, green:0.6, blue:0.87, alpha:1)

    /// Formatter for displaying the current value
    let formatter = NumberFormatter()
    
    /**
        Width of the sliding animation. When buttons clicked, the middle label does a slide animation towards to the clicked button. Defaults to 5.
    */
    let labelSlideLength: CGFloat = 5


    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.leftButtonText, for: .normal)
        button.setTitleColor(self.buttonsTextColor, for: .normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.borderWidth = 0.0
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GMStepper.handleLeftLongPress(gesture:)))
        longPressGestureRecognizer.minimumPressDuration = 1.0
        longPressGestureRecognizer.allowableMovement = 50
        button.addGestureRecognizer(longPressGestureRecognizer)
        let shortPressGesture = UITapGestureRecognizer(target: self, action: #selector(handleLeftShortPress))
        shortPressGesture.numberOfTapsRequired = 1
        button.addGestureRecognizer(shortPressGesture)
        return button
    }()

    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.rightButtonText, for: .normal)
        button.setTitleColor(self.buttonsTextColor, for: .normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.borderWidth = 0.0
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GMStepper.handleRightLongPress(gesture:)))
        longPressGestureRecognizer.minimumPressDuration = 1.0
        longPressGestureRecognizer.allowableMovement = 50
        button.addGestureRecognizer(longPressGestureRecognizer)
        let shortPressGesture = UITapGestureRecognizer(target: self, action: #selector(handleRightShortPress))
        shortPressGesture.numberOfTapsRequired = 1
        button.addGestureRecognizer(shortPressGesture)
        return button
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = formattedValue
        label.textColor = self.labelTextColor
        label.backgroundColor = self.labelBackgroundColor
        label.font = self.labelFont
        label.layer.cornerRadius = self.labelCornerRadius
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        return label
    }()

    var labelOriginalCenter: CGPoint!
    var labelMaximumCenterX: CGFloat!
    var labelMinimumCenterX: CGFloat!

    enum StepperState {
        case Stable, ShouldIncrease, ShouldDecrease, MoreIncrease, MoreDecrease
    }
    var stepperState = StepperState.Stable {
        didSet {
            if stepperState != .Stable {
                updateValue()
            }
        }
    }
    
    
    @objc public var items : [String] = [] {
        didSet {
            label.text = formattedValue
        }
    }

    /// Timer used for autorepeat option
    var timer: Timer?

    let timerInterval = TimeInterval(0.7)

    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    fileprivate func setup() {
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(label)
        backgroundColor = buttonsBackgroundColor
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        labelOriginalCenter = label.center
        setupNumberFormatter()
        NotificationCenter.default.addObserver(self, selector: #selector(GMStepper.reset), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func setupNumberFormatter() {
        let decValue = Decimal(stepValue)
        let digits = decValue.significantFractionalDecimalDigits
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = showIntegerIfDoubleIsInteger ? 0 : digits
        formatter.maximumFractionDigits = digits
    }

    public override func layoutSubviews() {
        let buttonWidth = bounds.size.width * ((1 - labelWidthWeight) / 2)
        let labelWidth = bounds.size.width * labelWidthWeight
        leftButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: bounds.size.height)
        label.frame = CGRect(x: buttonWidth, y: 0, width: labelWidth, height: bounds.size.height)
        rightButton.frame = CGRect(x: labelWidth + buttonWidth, y: 0, width: buttonWidth, height: bounds.size.height)
        labelMaximumCenterX = label.center.x + labelSlideLength
        labelMinimumCenterX = label.center.x - labelSlideLength
        labelOriginalCenter = label.center
    }

    @objc func updateValue() {
        if stepperState == .ShouldIncrease {
            value += stepValue
        } else if stepperState == .ShouldDecrease {
            value -= stepValue
        } else if stepperState == .MoreIncrease {
            value += 10
        } else if stepperState == .MoreDecrease {
            value -= 10
        }
    }
    

    deinit {
        resetTimer()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: LongPress Gesture
extension GMStepper {
    @objc func handleRightLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
            }
            stepperState = .MoreIncrease
        case .ended, .cancelled, .failed:
            reset()
        default:
            break
        }
    }
    
    @objc func handleLeftLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
            }
            stepperState = .MoreDecrease
        case .ended, .cancelled, .failed:
            reset()
        default:
            break
        }
    }

    @objc func reset() {
        stepperState = .Stable
        resetTimer()
        leftButton.isEnabled = true
        rightButton.isEnabled = true
    }
}

// MARK: Button Events
extension GMStepper {
    @objc func handleLeftShortPress(gesture: UITapGestureRecognizer) {
        rightButton.isEnabled = false
        if value != minimumValue {
            stepperState = .ShouldDecrease
        }
        reset()
    }
    
    @objc func handleRightShortPress(gesture: UITapGestureRecognizer) {
        leftButton.isEnabled = false
        if value != maximumValue {
            stepperState = .ShouldIncrease
        }
        reset()
    }
}

// MARK: Timer
extension GMStepper {
    @objc func handleTimer(timer: Timer) {
        updateValue()
    }

    func scheduleTimer() {
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(GMStepper.handleTimer), userInfo: nil, repeats: true)
    }

    func resetTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
}


extension Decimal {
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}


