//
//  ViewController.swift
//  RikApp
//
//  Created by Егор Худяев on 24.11.2025.
//

import UIKit
import BusinessLogicFramework
import NetworkLayerFramework

class ViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        setupScrollView()
        setupPullToRefresh()
        loadDataFromCacheOrServer()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, constant: 1)
        ])
        
        contentView.backgroundColor = .clear
    }
    
    private func setupPullToRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        print("Pull-to-refresh: принудительное обновление данных")
        Task {
            let (stats, users) = await DataService.shared.refreshAllData()
            if let stats = stats {
                print("Обновленные статистики: \(stats.statistics)")
            }
            if let users = users {
                print("Обновленные пользователи: \(users.users)")
            }
            await MainActor.run {
                refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadDataFromCacheOrServer() {
        print("Открытие раздела: проверка данных в базе данных")
        Task {
            let (stats, users) = await DataService.shared.loadAllData()
            if let stats = stats {
                print("Загруженные статистики: \(stats.statistics)")
            }
            if let users = users {
                print("Загруженные пользователи: \(users.users)")
            }
        }
    }
}

