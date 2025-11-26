//
//  UIViewControllerExtension.swift
//  RikApp
//
//  Created by Егор Худяев on 24.11.2025.
//

import UIKit

extension UIViewController {
    func showErrorAlert(message: String, title: String = "Ошибка") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
