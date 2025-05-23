import UIKit
import SwiftUI

class DashboardViewController: UIViewController {
    private let expenseManager = ExpenseManager.shared
    
    private let totalExpensesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textAlignment = .center
        label.textColor = .label
        label.backgroundColor = .systemBackground
        label.text = ""
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .systemBackground
        return collection
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(ExpenseTableViewCell.self, forCellReuseIdentifier: ExpenseTableViewCell.reuseIdentifier)
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        table.refreshControl = refreshControl
        return table
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        title = "Expense Tracker"
        navigationItem.rightBarButtonItem = addButton
        expenseManager.delegate = self
        updateTotalExpensesLabel()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(totalExpensesLabel)
        view.addSubview(collectionView)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        totalExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            totalExpensesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            totalExpensesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalExpensesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalExpensesLabel.heightAnchor.constraint(equalToConstant: 60),
            
            collectionView.topAnchor.constraint(equalTo: totalExpensesLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 0),
            
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let columns = UIDevice.current.userInterfaceIdiom == .pad ? 4 : (UIDevice.current.orientation.isLandscape ? 3 : 2)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
        group.interItemSpacing = .fixed(8)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @objc private func addButtonTapped() {
        let addExpenseView = AddExpenseView(expenseManager: expenseManager) { [weak self] expense in
            self?.expenseManager.addExpense(expense)
        }
        let hostingController = UIHostingController(rootView: addExpenseView)
        present(hostingController, animated: true)
    }
    
    @objc private func refreshData() {
        tableView.reloadData()
        collectionView.reloadData()
        updateTotalExpensesLabel()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func updateTotalExpensesLabel() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let total = expenseManager.totalAllCategories()
        totalExpensesLabel.text = "Total Expenses: \(formatter.string(from: NSNumber(value: total)) ?? "$0.00")"
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let expenses = expenseManager.expenses(for: expenseManager.selectedCategory).sorted { $0.date > $1.date }
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.reuseIdentifier, for: indexPath) as! ExpenseTableViewCell
        let expenses = expenseManager.expenses(for: expenseManager.selectedCategory).sorted { $0.date > $1.date }
        cell.configure(with: expenses[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let expenses = expenseManager.expenses(for: expenseManager.selectedCategory).sorted { $0.date > $1.date }
        print("Selected expense: \(expenses[indexPath.row])")
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ExpenseCategory.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        let category = ExpenseCategory.allCases[indexPath.row]
        let amount = expenseManager.total(for: category)
        cell.configure(with: category, amount: amount)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = ExpenseCategory.allCases[indexPath.row]
        if expenseManager.selectedCategory == category {
            expenseManager.selectedCategory = nil
        } else {
            expenseManager.selectedCategory = category
        }
        tableView.reloadData()
    }
}

// MARK: - ExpenseManagerDelegate
extension DashboardViewController: ExpenseManagerDelegate {
    func expenseManagerDidUpdate(_ manager: ExpenseManager) {
        tableView.reloadData()
        collectionView.reloadData()
        updateTotalExpensesLabel()
    }
} 