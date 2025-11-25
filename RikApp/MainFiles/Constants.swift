//
//  Constants.swift
//  RikApp
//
//  Created by Егор Худяев on 24.11.2025.
//

import UIKit

enum Constants {
    enum Colors {
        case black, red, orange, gray, backColor
        
        var color: UIColor {
            switch self {
            case .black:
                return .black
            case .red:
                return UIColor(red: 255/255, green: 46/255, blue: 0/255, alpha: 1)
            case .orange:
                return UIColor(red: 249/255, green: 153/255, blue: 99/255, alpha: 1)
            case .gray:
                return UIColor(red: 167/255, green: 167/255, blue: 177/255, alpha: 1)
            case .backColor:
                return UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
            }
        }
    }
    
    enum AppFont {
        case light(size: CGFloat)
        case medium(size: CGFloat)
        case bold(size: CGFloat)
        
        var font: UIFont {
            switch self {
            case .light(let size):
                return UIFont(name: "Gilroy-Light", size: size) ?? UIFont.systemFont(ofSize: size)
            case .medium(let size):
                return UIFont(name: "Gilroy-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
            case .bold(let size):
                return UIFont(name: "Gilroy-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
            }
        }
    }
}
