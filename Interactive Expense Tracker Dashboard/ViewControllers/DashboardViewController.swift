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
            collectionView.widthAnchor.constraint(equalToConstant: 120), // Fixed width for vertical bar
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: totalExpensesLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        group.interItemSpacing = .fixed(12)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8)
        section.orthogonalScrollingBehavior = .none // vertical scroll
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
        return ExpenseCategory.allCases.count + 1 // +1 for 'Show All'
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        if indexPath.row == 0 {
            // Show All cell
            let total = expenseManager.totalAllCategories()
            let selected = expenseManager.selectedCategory == nil
            cell.configureAsShowAll(total: total, selected: selected)
        } else {
            let category = ExpenseCategory.allCases[indexPath.row - 1]
            let amount = expenseManager.total(for: category)
            let selected = expenseManager.selectedCategory == category
            cell.configure(with: category, amount: amount, selected: selected)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            expenseManager.selectedCategory = nil
        } else {
            let category = ExpenseCategory.allCases[indexPath.row - 1]
            if expenseManager.selectedCategory == category {
                expenseManager.selectedCategory = nil
            } else {
                expenseManager.selectedCategory = category
            }
        }
        collectionView.reloadData()
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