//
//  MainViewController.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout
import NetworkLayerFramework
import BusinessLogicFramework
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    private let loadingBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.backColor.color
        setupNavigation()
        setupTableView()
        setupPullToRefresh()
        handleInitialDataLoad()
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

    // MARK: - Loading UI

    private func showLoadingOverlay() {
        guard loadingBlurView.superview == nil else { return }

        loadingBlurView.frame = view.bounds
        loadingBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(loadingBlurView)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingBlurView.contentView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingBlurView.contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingBlurView.contentView.centerYAnchor)
        ])

        activityIndicator.startAnimating()
    }

    private func hideLoadingOverlay() {
        activityIndicator.stopAnimating()
        loadingBlurView.removeFromSuperview()
    }

    private func setupPullToRefresh() {
        tableView.refreshControl = refreshControl
        
        refreshControl.rx.controlEvent(.valueChanged)
            .flatMapLatest { [weak self] _ -> Observable<DataResult> in
                guard let self = self else {
                    return Observable.empty()
                }
                print("Pull-to-refresh: принудительное обновление данных")
                return DataService.shared.refreshAllDataObservable()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                print("Обновленные статистики: \(result.statistics.statistics)")
                print("Обновленные пользователи: \(result.users.users)")
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }, onError: { [weak self] error in
                guard let self = self else { return }
                print("Ошибка обновления данных: \(error)")
                self.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Data Loading
    
    private func hasCachedData() -> Bool {
        let hasStats = !DataService.shared.getViewStatistics().isEmpty
        let hasUsers = !DataService.shared.getCachedUsers().isEmpty
        return hasStats && hasUsers
    }

    private func handleInitialDataLoad() {
        if hasCachedData() {
            print("Найдены кэшированные данные, показываем экран без лоадера")
            DataService.shared.loadAllDataObservable()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] result in
                    guard let self = self else { return }
                    print("Загруженные статистики: \(result.statistics.statistics)")
                    print("Загруженные пользователи: \(result.users.users)")
                    self.tableView.reloadData()
                }, onError: { error in
                    print("Ошибка загрузки данных: \(error)")
                })
                .disposed(by: disposeBag)
        } else {
            print("Кэшированных данных нет, показываем лоадер и загружаем данные")
            showLoadingOverlay()
            DataService.shared.loadAllDataObservable()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] result in
                    guard let self = self else { return }
                    print("Загруженные статистики: \(result.statistics.statistics)")
                    print("Загруженные пользователи: \(result.users.users)")
                    self.hideLoadingOverlay()
                    self.tableView.reloadData()
                }, onError: { [weak self] error in
                    guard let self = self else { return }
                    print("Ошибка загрузки данных: \(error)")
                    self.hideLoadingOverlay()
                })
                .disposed(by: disposeBag)
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0: return tableView.dequeueReusableCell(withIdentifier: "VisitorsSummaryCell", for: indexPath)
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VisitorsChartCell", for: indexPath) as! VisitorsChartCell
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

            cell.loadTopVisitors()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenderAgeCell", for: indexPath) as! GenderAgeCell
            cell.loadInitialData()
            return cell
        default: return tableView.dequeueReusableCell(withIdentifier: "FollowersSummaryCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0, let summaryCell = cell as? VisitorsSummaryCell {
            summaryCell.loadTotalVisitors()
        } else if indexPath.row == 1, let chartCell = cell as? VisitorsChartCell {
            chartCell.loadChartData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
