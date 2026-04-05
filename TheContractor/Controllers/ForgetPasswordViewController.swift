//
//  ForgetPasswordViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/26/21.
//

import UIKit
import MBProgressHUD

class ForgetPasswordViewController: UIViewController {

    // MARK: - UI Components (all programmatic)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let phoneField = UITextField()
    private let passwordField = UITextField()
    private let confirmPasswordField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let errorLabel = UILabel()

    private let yellow = UIColor(red: 242/255, green: 190/255, blue: 54/255, alpha: 1)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = UIColor.systemGroupedBackground
        setupTopBar()
        setupScrollContent()
        addKeyboardObservers()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Layout
    private func setupTopBar() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        let barH: CGFloat = 56 + safeTop
        topBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: barH)
        topBar.backgroundColor = yellow
        topBar.autoresizingMask = [.flexibleWidth]
        view.addSubview(topBar)

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.frame = CGRect(x: 8, y: safeTop, width: 44, height: 56)
        backButton.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
        topBar.addSubview(backButton)

        titleLabel.text = "Forgot Password"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.frame = CGRect(x: 56, y: safeTop, width: view.bounds.width - 70, height: 56)
        topBar.addSubview(titleLabel)
    }

    private func setupScrollContent() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        let topBarBottom = 56 + safeTop
        scrollView.frame = CGRect(x: 0, y: topBarBottom, width: view.bounds.width,
                                   height: view.bounds.height - topBarBottom)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let padding: CGFloat = 20
        var y: CGFloat = 32

        func addLabel(_ text: String) -> UILabel {
            let lbl = UILabel()
            lbl.text = text
            lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            lbl.textColor = .darkGray
            lbl.frame = CGRect(x: padding, y: y, width: view.bounds.width - padding * 2, height: 20)
            contentView.addSubview(lbl)
            y += 26
            return lbl
        }

        func addField(_ field: UITextField, placeholder: String, isSecure: Bool = false) {
            field.placeholder = placeholder
            field.isSecureTextEntry = isSecure
            field.borderStyle = .none
            field.backgroundColor = .white
            field.layer.cornerRadius = 8
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.systemGray4.cgColor
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
            field.leftViewMode = .always
            field.frame = CGRect(x: padding, y: y, width: view.bounds.width - padding * 2, height: 48)
            contentView.addSubview(field)
            y += 60
        }

        // Instruction
        let instrLabel = UILabel()
        instrLabel.text = "Enter your registered phone number and a new password to reset your account password."
        instrLabel.font = UIFont.systemFont(ofSize: 14)
        instrLabel.textColor = .darkGray
        instrLabel.numberOfLines = 0
        instrLabel.frame = CGRect(x: padding, y: y, width: view.bounds.width - padding * 2, height: 0)
        instrLabel.sizeToFit()
        instrLabel.frame.origin = CGPoint(x: padding, y: y)
        contentView.addSubview(instrLabel)
        y += instrLabel.bounds.height + 24

        // Phone field
        addLabel("Phone Number (+971XXXXXXXXX)")
        phoneField.keyboardType = .phonePad
        phoneField.autocorrectionType = .no
        addField(phoneField, placeholder: "+971XXXXXXXXX")

        // Country code prefix
        let prefixLabel = UILabel()
        prefixLabel.text = "+971 "
        prefixLabel.font = UIFont.systemFont(ofSize: 15)
        prefixLabel.textColor = .darkGray
        prefixLabel.sizeToFit()
        let prefixContainer = UIView(frame: CGRect(x: 0, y: 0, width: prefixLabel.frame.width + 12, height: 48))
        prefixLabel.frame.origin = CGPoint(x: 8, y: (48 - prefixLabel.frame.height) / 2)
        prefixContainer.addSubview(prefixLabel)
        phoneField.leftView = prefixContainer
        phoneField.leftViewMode = .always
        phoneField.placeholder = "5XXXXXXXX"

        // New password field
        addLabel("New Password")
        addField(passwordField, placeholder: "Enter new password", isSecure: true)

        // Confirm password field
        addLabel("Confirm New Password")
        addField(confirmPasswordField, placeholder: "Confirm new password", isSecure: true)

        // Error label
        errorLabel.font = UIFont.systemFont(ofSize: 13)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.frame = CGRect(x: padding, y: y, width: view.bounds.width - padding * 2, height: 0)
        errorLabel.isHidden = true
        contentView.addSubview(errorLabel)
        y += 20

        // Submit button
        submitButton.setTitle("Reset Password", for: .normal)
        submitButton.backgroundColor = yellow
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        submitButton.layer.cornerRadius = 8
        submitButton.frame = CGRect(x: padding, y: y + 12, width: view.bounds.width - padding * 2, height: 50)
        submitButton.addTarget(self, action: #selector(actionSubmit), for: .touchUpInside)
        contentView.addSubview(submitButton)
        y += 80

        contentView.frame.size.height = y + 40
        let heightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: y + 40)
        heightConstraint.isActive = true
    }

    // MARK: - Actions
    @IBAction func actionBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func actionSubmit() {
        guard let phone = phoneField.text, !phone.isEmpty else {
            showError("Please enter your phone number.")
            return
        }
        guard let password = passwordField.text, password.count >= 6 else {
            showError("Password must be at least 6 characters.")
            return
        }
        guard confirmPasswordField.text == password else {
            showError("Passwords do not match.")
            return
        }

        let fullPhone = phone.hasPrefix("+") ? phone : "+971\(phone)"

        MBProgressHUD.showAdded(to: view, animated: true)
        let url = "https://contractor.bidcont.com/rest/Account/forgot_password"
        let params: [String: String] = ["user_phone": fullPhone, "new_password": password]
        LoginService.shared().makePostAPICall(with: url, params: params) { [weak self] message, success, _, _ in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self?.view ?? UIView(), animated: true)
                if success {
                    self?.showSuccessAlert(message: message.isEmpty ? "Password reset successfully." : message)
                } else {
                    self?.showError(message.isEmpty ? "Could not reset password. Please try again." : message)
                }
            }
        }
    }

    private func showError(_ msg: String) {
        errorLabel.text = msg
        errorLabel.isHidden = false
        errorLabel.sizeToFit()
    }

    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    // MARK: - Keyboard handling
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = kbSize.height + 20
        }
    }

    @objc private func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
    }
}
