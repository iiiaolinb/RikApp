//
//  ImageCacheService.swift
//  BusinessLogicFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation
import UIKit

public final class ImageCacheService {
    public static let shared = ImageCacheService()
    
    private let cacheDirectory: URL
    private let fileManager = FileManager.default
    private let session: URLSession
    
    private init() {
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cacheDir.appendingPathComponent("UserImages", isDirectory: true)
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, // 50 MB
                                         diskCapacity: 200 * 1024 * 1024,   // 200 MB
                                         diskPath: cacheDirectory.path)
        session = URLSession(configuration: configuration)
        
        print("ImageCacheService инициализирован. Кеш директория: \(cacheDirectory.path)")
    }
    
    // MARK: - Public Methods
    
    public func loadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("Некорректный URL: \(urlString)")
            return nil
        }
        
        if let cachedImage = loadFromDiskCache(url: url) {
            print("Изображение загружено из кеша: \(urlString)")
            return cachedImage
        }
        
        return await downloadImage(from: url)
    }
    
    // MARK: - Private Methods
    
    private func loadFromDiskCache(url: URL) -> UIImage? {
        let cacheKey = getCacheKey(for: url)
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    /// Загружает изображение с сервера и сохраняет в кеш
    private func downloadImage(from url: URL) async -> UIImage? {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                print("Ошибка загрузки изображения: неверный статус код")
                return nil
            }
            
            guard let image = UIImage(data: data) else {
                print("Ошибка: не удалось создать UIImage из данных")
                return nil
            }
            
            // Сохраняем в кеш на диск
            saveToDiskCache(data: data, url: url)
            
            print("Изображение успешно загружено и сохранено в кеш: \(url.absoluteString)")
            return image
            
        } catch {
            print("Ошибка загрузки изображения: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Сохраняет изображение в кеш на диске
    private func saveToDiskCache(data: Data, url: URL) {
        let cacheKey = getCacheKey(for: url)
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Ошибка сохранения изображения в кеш: \(error)")
        }
    }
    
    /// Генерирует ключ кеша для URL
    private func getCacheKey(for url: URL) -> String {
        let urlString = url.absoluteString
        let hash = urlString.hash
        let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
        return "\(abs(hash)).\(fileExtension)"
    }
}

