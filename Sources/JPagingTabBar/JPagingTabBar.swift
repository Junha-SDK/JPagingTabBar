import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

public class JPagingTabBar: UIView {
    
    private var categoryTitleList: [String]
    
    public let selectedIndex = PublishSubject<Int>()
    
    public let itemSelected = PublishSubject<IndexPath>()
    
    private let disposeBag = DisposeBag()
    
    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.backgroundColor = .clear
        collectionView.register(JPagingTabBarCell.self,
                                forCellWithReuseIdentifier:
                                    JPagingTabBarCell.identifier)
        
        collectionView.isScrollEnabled = categoryTitleList.count >= 7
        
        Observable.just(categoryTitleList).bind(to:
                                                    collectionView.rx.items(
                                                        cellIdentifier: JPagingTabBarCell.identifier,
                                                        cellType: JPagingTabBarCell.self)) { _, title, cell in
                                                            cell.setupView(title: title)
                                                        }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.bind(to: self.itemSelected).disposed(by: self.disposeBag)
        
        return collectionView
    }()
    
    private lazy var grayUnderline = UIView().then {
        $0.backgroundColor = .gray
        $0.alpha = 1.0
    }
    
    private func calculateCellWidth(text: String) -> Double {
        let nonSpaceCount = text.filter { !$0.isWhitespace }.count
        let spaceCount = text.filter { $0.isWhitespace }.count
        
        let textWidth = Double((Double(nonSpaceCount) * 18) + (Double(spaceCount) * 5) + 8)
        return textWidth
    }
    
    public init(categoryTitleList: [String]) {
        self.categoryTitleList = categoryTitleList
        super.init(frame: .zero)
        setupLayout()
        
        self.collectionView.selectItem(at:
                                        IndexPath(row: 0, section: 0),
                                       animated: true,
                                       scrollPosition: []
        )
        
        collectionView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let strongSelf = self else { return }
            strongSelf.selectedIndex.onNext(indexPath.row)
        }).disposed(by: self.disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func selectItem(at index: Int) {
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        selectedIndex.onNext(index)
    }
}

extension JPagingTabBar: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cellWidth = calculateCellWidth(text: categoryTitleList[indexPath.row])
        return CGSize(width: cellWidth, height: 56.0)
    }
}

extension JPagingTabBar: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryTitleList.count
    }
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JPagingTabBarCell.identifier,
            for: indexPath) as? JPagingTabBarCell else { return UICollectionViewCell() }
        
        cell.setupView(title: categoryTitleList[indexPath.row])
        
        return cell
    }
}

private extension JPagingTabBar {
    func setupLayout() {
        addSubview(grayUnderline)
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        grayUnderline.snp.makeConstraints {
            $0.width.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
}
