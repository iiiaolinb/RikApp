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
    /// - Parameters:
    ///   - urlString: URL изображения в виде строки
    ///   - placeholder: Изображение-заглушка, пока загружается основное
    ///   - completion: Колбэк с загруженным изображением (или nil при ошибке)
    func loadImage(from urlString: String?, placeholder: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
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
                completion?(image)
            }
        }
    }
    
    /// Загружает аватар пользователя
    /// - Parameters:
    ///   - user: Пользователь, чей аватар нужно загрузить
    ///   - placeholder: Изображение-заглушка
    ///   - completion: Колбэк с загруженным изображением (или nil при ошибке)
    func loadAvatar(for user: NetworkLayerFramework.User, placeholder: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        let avatarURL = user.files.first { $0.type == .avatar }?.url
        loadImage(from: avatarURL, placeholder: placeholder, completion: completion)
    }
}

