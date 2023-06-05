//
//  SectionHeaderFooterViewController.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/06/05.
//

import UIKit

final class SectionHeaderFooterViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!

    static func instantiate() -> SectionHeaderFooterViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! SectionHeaderFooterViewController
        return viewController
    }

    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        setupDataSource()
        setupInitialData()
    }

    private func setupCollectionViewLayout() {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5.0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            ),
            elementKind: "Header",
            alignment: .top
        )
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            ),
            elementKind: "Footer",
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }

    private func setupDataSource() {
        let headerRegistration = UICollectionView
            .SupplementaryRegistration<TitleSupplementaryView>(
                elementKind: "Header"
            ) { supplementaryView, elementKind, indexPath in
                supplementaryView.label.text = "\(elementKind) for section \(indexPath.section)"
                supplementaryView.backgroundColor = .systemTeal
                supplementaryView.layer.borderColor = UIColor.black.cgColor
                supplementaryView.layer.borderWidth = 1.0
            }
        let footerRegistration = UICollectionView
            .SupplementaryRegistration<TitleSupplementaryView>(
                elementKind: "Footer"
            ) { supplementaryView, elementKind, indexPath in
                supplementaryView.label.text = "\(elementKind) for section \(indexPath.section)"
                supplementaryView.backgroundColor = .systemMint
                supplementaryView.layer.borderColor = UIColor.black.cgColor
                supplementaryView.layer.borderWidth = 1.0
            }
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, Int> { cell, indexPath, item in
                var content = cell.defaultContentConfiguration()
                content.text = "\(item)"
                cell.contentConfiguration = content
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.gray.cgColor
        }
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(
            collectionView: collectionView
        ) { collectionView, indexPath, identifier in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: identifier
            )
        }
        dataSource.supplementaryViewProvider = { [unowned self] view, kind, indexPath in
            return self.collectionView
                .dequeueConfiguredReusableSupplementary(
                    using: kind == "Header" ? headerRegistration : footerRegistration,
                    for: indexPath
                )
        }
    }

    private func setupInitialData() {
        let itemsPerSection = 5
        let sections = Array(0..<5)
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var itemOffset = 0
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems(Array(itemOffset..<itemOffset + itemsPerSection))
            itemOffset += itemsPerSection
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

class TitleSupplementaryView: UICollectionReusableView {
    let label = UILabel()
    static let reuseIdentifier = "title-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension TitleSupplementaryView {
    func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        label.font = UIFont.preferredFont(forTextStyle: .title3)
    }
}
