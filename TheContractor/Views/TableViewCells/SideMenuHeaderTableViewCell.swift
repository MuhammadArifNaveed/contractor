//
//  SideMenuHeaderTableViewCell.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/24/21.
//

import UIKit

class SideMenuHeaderTableViewCell: UITableViewCell {

    var onLoginTap: (() -> Void)?
    var onLoginAsCompanyTap: (() -> Void)?
    var onViewProfileTap: (() -> Void)?

    // MARK: - Guest views
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login or Create Account  >", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.cornerRadius = 6
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let loginAsCompanyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login or Create Account as Company", for: .normal)
        btn.setTitleColor(UIColor(red: 242/255, green: 190/255, blue: 54/255, alpha: 1), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn.contentHorizontalAlignment = .left
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let guestStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Logged-in views
    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 242/255, green: 190/255, blue: 54/255, alpha: 1)
        v.layer.cornerRadius = 28
        v.translatesAutoresizingMaskIntoConstraints = false
        let img = UIImageView(image: UIImage(systemName: "person.fill"))
        img.tintColor = .white
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(img)
        NSLayoutConstraint.activate([
            img.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            img.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            img.widthAnchor.constraint(equalToConstant: 28),
            img.heightAnchor.constraint(equalToConstant: 28)
        ])
        return v
    }()

    private let userNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .black
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let viewProfileButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("View Profile  >", for: .normal)
        btn.setTitleColor(UIColor(red: 242/255, green: 190/255, blue: 54/255, alpha: 1), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn.contentHorizontalAlignment = .left
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let userInfoStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let loggedInStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .white

        // Remove any storyboard-loaded subviews to prevent overlap
        contentView.subviews.forEach { $0.removeFromSuperview() }

        // Guest stack
        guestStack.addArrangedSubview(loginButton)
        guestStack.addArrangedSubview(loginAsCompanyButton)
        contentView.addSubview(guestStack)

        // Logged-in stack
        userInfoStack.addArrangedSubview(userNameLabel)
        userInfoStack.addArrangedSubview(viewProfileButton)
        loggedInStack.addArrangedSubview(avatarView)
        loggedInStack.addArrangedSubview(userInfoStack)
        contentView.addSubview(loggedInStack)

        NSLayoutConstraint.activate([
            // Login button height
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            // Avatar size
            avatarView.widthAnchor.constraint(equalToConstant: 56),
            avatarView.heightAnchor.constraint(equalToConstant: 56),
            // Guest stack
            guestStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            guestStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            guestStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            // Logged-in stack
            loggedInStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            loggedInStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loggedInStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginAsCompanyButton.addTarget(self, action: #selector(loginAsCompanyTapped), for: .touchUpInside)
        viewProfileButton.addTarget(self, action: #selector(viewProfileTapped), for: .touchUpInside)
    }

    // MARK: - Configure
    func configure(isLoggedIn: Bool, userName: String? = nil) {
        if isLoggedIn {
            guestStack.isHidden = true
            loggedInStack.isHidden = false
            userNameLabel.text = userName ?? "User"
        } else {
            guestStack.isHidden = false
            loggedInStack.isHidden = true
        }
    }

    // MARK: - Actions
    @objc private func loginTapped() { onLoginTap?() }
    @objc private func loginAsCompanyTapped() { onLoginAsCompanyTap?() }
    @objc private func viewProfileTapped() { onViewProfileTap?() }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
