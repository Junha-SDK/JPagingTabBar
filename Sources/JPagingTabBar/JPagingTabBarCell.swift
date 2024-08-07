import UIKit
import Then
import SnapKit

public class JPagingTabBarCell: UICollectionViewCell {
    
    static let identifier = "JPagingTabBarCell"
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20)
        $0.textColor = .gray
        $0.textAlignment = .center
    }

    private lazy var underline = UIView().then {
        $0.backgroundColor = .blue
        $0.alpha = 0.0
    }
    
    public override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? .black : .gray
            underline.alpha = isSelected ? 1.0 : 0.0
        }
    }
    
    func setupView(title: String) {
        setupLayout()
        titleLabel.text = title
    }
}

private extension JPagingTabBarCell {
    func setupLayout() {
        [
            titleLabel,
            underline
        ].forEach { addSubview($0) }
        titleLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        underline.snp.makeConstraints {
            $0.height.equalTo(2.0)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4.0)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
