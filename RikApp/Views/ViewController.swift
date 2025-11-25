//
//  ViewController.swift
//  RikApp
//
//  Created by Егор Худяев on 24.11.2025.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        fetchData()
    }
    
    private func fetchData() {
        Task {
            await fetchStatistics()
            await fetchUsers()
        }
    }

    private func fetchStatistics() async {
        let statsResult = await NetworkAssistent.shared.fetchStatistics()
        switch statsResult {
        case .success(let stats):
            print("Statistics:", stats.statistics)
        case .failure(let error):
            print("Failed to fetch statistics:", error)
            self.showErrorAlert(error)
        }
    }
    
    private func fetchUsers() async {
        let usersResult = await NetworkAssistent.shared.fetchUsers()
        switch usersResult {
        case .success(let users):
            print("Users:", users.users)
        case .failure(let error):
            print("Failed to fetch users:", error)
            self.showErrorAlert(error)
        }
    }
}

