//
//  ViewController.swift
//  ScorpCaseStudy
//
//  Created by Sadık Çoban on 25.02.2023.
//

import UIKit

final class PersonListViewController: UIViewController {
    
    private var viewModel = PersonListViewModel()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.refreshControl = refreshControl
        view.allowsSelection = false
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(reloadTableData), for: .valueChanged)
        return view
    }()
    
    private lazy var noDataView: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.text = "No one here :)\nPull to refresh..."
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        setupConsts()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.personList.isEmpty {
            reloadTableData()
        }
    }
    
    private func addSubviews(){
        view.addSubview(tableView)
        view.addSubview(noDataView)
    }
    
    private func setupConsts(){
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            noDataView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noDataView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
        
    }
    
    @objc private func reloadTableData(paginate: Bool = false) {
        viewModel.loadData(paginate: paginate) {[weak self] in
            DispatchQueue.main.async {
                self?.refreshTableView()
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func refreshTableView(){
        if viewModel.personList.isEmpty {
            self.noDataView.isHidden = false
        } else {
            self.noDataView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
}

extension PersonListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.personList.isEmpty {
            return 0
        } else {
            if viewModel.canLoadData {
                return viewModel.personList.count + 1
            } else {
                return viewModel.personList.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < viewModel.personList.count {
            let cell = UITableViewCell()
            cell.textLabel?.text = viewModel.personList[indexPath.row].fullName
            return cell
        } else {
            if viewModel.canLoadData {
                let cell = UITableViewCell()
                let indicator = UIActivityIndicatorView()
                indicator.color = .red
                indicator.startAnimating()
                indicator.translatesAutoresizingMaskIntoConstraints = false
                indicator.hidesWhenStopped = true
                cell.addSubview(indicator)
                indicator.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                indicator.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
                return cell
            } else {
                return UITableViewCell()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.canLoadData && indexPath.row == viewModel.personList.count {
            reloadTableData(paginate: true)
        }
        
    }

}

