//
//  VisitorRow.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout

protocol VisitorRowViewDelegate: AnyObject {
    func visitorRowView(_ view: VisitorRowView, didTap visitor: TopVisitorsCell.Visitor)
}

final class VisitorRowView: UIView {

    private let avatar = UIImageView()
    private let initialLabel = UILabel()
    private let onlineDot = UIView()

    private let nameLabel = UILabel()
    private let arrow = UIImageView(image: UIImage(named: "arrowRight"))
    private let separator = UIView()

    private let visitor: TopVisitorsCell.Visitor
    private let isLast: Bool
    
    weak var delegate: VisitorRowViewDelegate?
    
    init(visitor: TopVisitorsCell.Visitor, isLast: Bool) {
        self.visitor = visitor
        self.isLast = isLast
        super.init(frame: .zero)

        setupAvatar()
        setupOnlineIndicator()

        nameLabel.text = "\(visitor.name), \(visitor.age) \(visitor.emoji)"
        nameLabel.font = Constants.AppFont.medium(size: 16).font
        nameLabel.textColor = Constants.Colors.black.color

        arrow.tintColor = .tertiaryLabel

        separator.backgroundColor = .lightGray.withAlphaComponent(0.5)
        separator.isHidden = isLast

        addSubview(avatar)
        addSubview(initialLabel)
        addSubview(onlineDot)
        addSubview(nameLabel)
        addSubview(arrow)
        addSubview(separator)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: – Avatar Placeholder

    private func setupAvatar() {
        avatar.layer.cornerRadius = 20
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFill

        // Плейсхолдер: серый фон + первая буква
        avatar.backgroundColor = UIColor(white: 0.9, alpha: 1)
        initialLabel.isHidden = false

        if let first = visitor.name.first {
            initialLabel.text = String(first).uppercased()
        }
        
        initialLabel.font = Constants.AppFont.bold(size: 18).font
        initialLabel.textColor = .darkGray
        initialLabel.textAlignment = .center

        // Загружаем аватар с кешированием; пока загружается или при ошибке
        // остается плейсхолдер (серый фон с буквой)
        avatar.loadAvatar(for: visitor.user) { [weak self] image in
            guard let self = self else { return }
            // Если аватар загрузился, прячем букву
            self.initialLabel.isHidden = (image != nil)
        }
    }

    private func setupOnlineIndicator() {
        onlineDot.backgroundColor = visitor.isOnline ? UIColor.systemGreen : UIColor.clear
        onlineDot.layer.cornerRadius = 6
        onlineDot.layer.borderWidth = 2
        onlineDot.layer.borderColor = UIColor.white.cgColor
        onlineDot.isHidden = !visitor.isOnline
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        avatar.pin
            .left(16)
            .vCenter()
            .size(40)

        initialLabel.pin
            .center(to: avatar.anchor.center)
            .size(40)

        onlineDot.pin
            .bottomRight(to: avatar.anchor.bottomRight)
            .marginBottom(-2)
            .marginRight(-2)
            .size(12)

        arrow.pin
            .right(16)
            .vCenter()
            .size(16)

        nameLabel.pin
            .after(of: avatar)
            .marginLeft(12)
            .before(of: arrow)
            .vCenter()
            .sizeToFit(.width)

        if !isLast {
            separator.pin
                .bottom()
                .left(nameLabel.frame.minX)
                .right(5)
                .height(1)
        }

        // Если аватар загрузился, скрываем инициал
        initialLabel.isHidden = (avatar.image != nil)
    }
    
    // MARK: – Actions
    
    @objc private func handleTap() {
        delegate?.visitorRowView(self, didTap: visitor)
    }
}
