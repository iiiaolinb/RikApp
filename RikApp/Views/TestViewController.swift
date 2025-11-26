//
//  TestViewController.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout
import NetworkLayerFramework
import BusinessLogicFramework

final class TestViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.backColor.color
        setupNavigation()
        setupTableView()
        setupPullToRefresh()
        loadDataFromCacheOrServer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.pin.all()
    }

    private func setupNavigation() {
        title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let standard = UINavigationBarAppearance()
        standard.configureWithOpaqueBackground()
        standard.backgroundColor = Constants.Colors.backColor.color
        standard.titleTextAttributes = [.foregroundColor: Constants.Colors.black.color]
        standard.largeTitleTextAttributes = [.foregroundColor: Constants.Colors.black.color]

        let scrollEdge = UINavigationBarAppearance()
        scrollEdge.configureWithTransparentBackground()
        scrollEdge.titleTextAttributes = [.foregroundColor: Constants.Colors.black.color]
        scrollEdge.largeTitleTextAttributes = [.foregroundColor: Constants.Colors.black.color]

        navigationController?.navigationBar.standardAppearance = standard
        navigationController?.navigationBar.scrollEdgeAppearance = scrollEdge
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.separatorStyle = .none

        tableView.register(VisitorsSummaryCell.self, forCellReuseIdentifier: "VisitorsSummaryCell")
        tableView.register(VisitorsChartCell.self, forCellReuseIdentifier: "VisitorsChartCell")
        tableView.register(TopVisitorsCell.self, forCellReuseIdentifier: "TopVisitorsCell")
        tableView.register(GenderAgeCell.self, forCellReuseIdentifier: "GenderAgeCell")
        tableView.register(FollowersSummaryCell.self, forCellReuseIdentifier: "FollowersSummaryCell")

        view.addSubview(tableView)
    }

    private func setupPullToRefresh() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
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
                self.refreshControl.endRefreshing()
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

extension TestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0: return tableView.dequeueReusableCell(withIdentifier: "VisitorsSummaryCell", for: indexPath)
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VisitorsChartCell", for: indexPath) as! VisitorsChartCell
            // Данные установим в willDisplay для гарантии правильного layout
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopVisitorsCell", for: indexPath) as! TopVisitorsCell
            cell.onUserSelected = { [weak self] user in
                guard let self = self else { return }
                let detailsVC = UserDetailsViewController(user: user)
                if let sheet = detailsVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                }
                self.present(detailsVC, animated: true)
            }
            return cell
        case 3: return tableView.dequeueReusableCell(withIdentifier: "GenderAgeCell", for: indexPath)
        default: return tableView.dequeueReusableCell(withIdentifier: "FollowersSummaryCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0, let summaryCell = cell as? VisitorsSummaryCell {
            summaryCell.loadTotalVisitors()
        } else if indexPath.row == 1, let chartCell = cell as? VisitorsChartCell {
            // Загружаем данные из Realm
            chartCell.loadChartData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
