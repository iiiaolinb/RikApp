//
//  UIImageViewExtension.swift
//  RikApp
//
//  Created by Егор Худяев on 24.11.2025.
//

import UIKit
import BusinessLogicFramework
import NetworkLayerFramework

extension UIImageView {
    /// Загружает изображение по URL с кешированием
    /// - Parameter urlString: URL изображения в виде строки
    /// - Parameter placeholder: Изображение-заглушка, пока загружается основное
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        guard let urlString = urlString, !urlString.isEmpty else {
            return
        }
        
        Task {
            let image = await ImageCacheService.shared.loadImage(from: urlString)
            
            await MainActor.run {
                if let image = image {
                    self.image = image
                }
            }
        }
    }
    
    /// Загружает аватар пользователя
    /// - Parameter user: Пользователь, чей аватар нужно загрузить
    /// - Parameter placeholder: Изображение-заглушка
    func loadAvatar(for user: NetworkLayerFramework.User, placeholder: UIImage? = nil) {
        let avatarURL = user.files.first { $0.type == .avatar }?.url
        loadImage(from: avatarURL, placeholder: placeholder)
    }
}

