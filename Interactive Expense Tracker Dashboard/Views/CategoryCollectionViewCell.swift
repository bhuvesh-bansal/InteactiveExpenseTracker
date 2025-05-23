import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCollectionViewCell"
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            updateSelectionAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        updateSelectionAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.systemTeal.cgColor
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        
        contentView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            categoryLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with category: ExpenseCategory, amount: Double, selected: Bool) {
        categoryLabel.text = category.rawValue
        isSelected = selected
    }
    
    func configureAsShowAll(total: Double, selected: Bool) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        categoryLabel.text = "All"
        isSelected = selected
    }
    
    private func updateSelectionAppearance() {
        if isSelected {
            contentView.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.2)
            categoryLabel.textColor = .black
        } else {
            contentView.backgroundColor = .white
            categoryLabel.textColor = .black
        }
    }
} 