//
//  TestViewController.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout

final class TestViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.backColor.color
        setupNavigation()
        setupTableView()
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
        case 2: return tableView.dequeueReusableCell(withIdentifier: "TopVisitorsCell", for: indexPath)
        case 3: return tableView.dequeueReusableCell(withIdentifier: "GenderAgeCell", for: indexPath)
        default: return tableView.dequeueReusableCell(withIdentifier: "FollowersSummaryCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 1, let chartCell = cell as? VisitorsChartCell {
            // Загружаем данные из Realm
            chartCell.loadChartData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
