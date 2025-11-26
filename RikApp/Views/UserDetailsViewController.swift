//
//  UserDetailsViewController.swift
//  RikApp
//
//  Created by AI on 26.11.2025.
//

import UIKit
import PinLayout
import NetworkLayerFramework
import BusinessLogicFramework

final class UserDetailsViewController: UIViewController {

    private let user: User

    private let avatarImageView = UIImageView()
    private let initialLabel = UILabel()
    private let nameLabel = UILabel()
    private let emojiContainer = UIView()
    private let emojiLabel = UILabel()

    // MARK: - Init

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Constants.Colors.backColor.color
        isModalInPresentation = false

        setupAvatar()
        setupNameLabel()
        setupEmojiView()
        
        startWaveAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        avatarImageView.pin
            .top(view.safeAreaInsets.top + 40)
            .hCenter()
            .size(120)

        initialLabel.pin
            .center(to: avatarImageView.anchor.center)
            .size(120)

        nameLabel.pin
            .below(of: avatarImageView)
            .marginTop(16)
            .horizontally(32)
            .sizeToFit(.width)

        emojiContainer.pin
            .below(of: nameLabel)
            .marginTop(24)
            .width(120)
            .height(120)
            .hCenter()

        emojiLabel.pin
            .center(to: emojiContainer.anchor.center)
            .sizeToFit()

        initialLabel.isHidden = (avatarImageView.image != nil)
    }

    // MARK: - Setup

    private func setupAvatar() {
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = UIColor(white: 0.9, alpha: 1)

        if let first = user.username.first {
            initialLabel.text = String(first).uppercased()
        }
        initialLabel.font = Constants.AppFont.bold(size: 40).font
        initialLabel.textColor = .darkGray
        initialLabel.textAlignment = .center

        view.addSubview(avatarImageView)
        view.addSubview(initialLabel)

        avatarImageView.loadAvatar(for: user) { [weak self] image in
            guard let self = self else { return }
            self.initialLabel.isHidden = (image != nil)
        }
    }

    private func setupNameLabel() {
        nameLabel.textAlignment = .center
        nameLabel.textColor = Constants.Colors.black.color
        nameLabel.font = Constants.AppFont.medium(size: 20).font
        nameLabel.text = "\(user.username), \(user.age)"

        view.addSubview(nameLabel)
    }

    private func setupEmojiView() {
        emojiContainer.backgroundColor = Constants.Colors.black.color.withAlphaComponent(0.05)
        emojiContainer.layer.cornerRadius = 24

        emojiLabel.text = "👋🏽"
        emojiLabel.font = Constants.AppFont.medium(size: 60).font
        emojiLabel.textAlignment = .center

        emojiContainer.addSubview(emojiLabel)
        view.addSubview(emojiContainer)
    }

    // MARK: - Animation

    private func startWaveAnimation() {
        wave(times: 2)
    }

    private func wave(times: Int) {
        guard times > 0 else {
            UIView.animate(withDuration: 0.2) {
                self.emojiLabel.transform = .identity
            }
            return
        }

        let angle: CGFloat = .pi / 6

        UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                self.emojiLabel.transform = CGAffineTransform(rotationAngle: angle)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.emojiLabel.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                self.emojiLabel.transform = CGAffineTransform(rotationAngle: angle / 2)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.emojiLabel.transform = .identity
            }
        }, completion: { _ in
            self.wave(times: times - 1)
        })
    }
}
