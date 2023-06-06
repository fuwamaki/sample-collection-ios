//
//  AdaptiveSectionViewController.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/06/06.
//

import UIKit

final class AdaptiveSectionViewController: UIViewController {

    enum SectionLayoutKind: Int, CaseIterable {
        case list
        case grid5
        case grid3

        func columnCount(for width: CGFloat) -> Int {
            let wideMode = width > 600
            switch self {
            case .list:
                return wideMode ? 2 : 1
            case .grid5:
                return wideMode ? 10 : 5
            case .grid3:
                return wideMode ? 6 : 3
            }
        }
    }

    @IBOutlet private weak var collectionView: UICollectionView!

    static func instantiate() -> AdaptiveSectionViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! AdaptiveSectionViewController
        return viewController
    }

    private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        setupDataSource()
        setupInitialData()
    }

    private func setupCollectionViewLayout() {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionLayoutKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }
            let columnCount = sectionLayoutKind.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0/CGFloat(columnCount)),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            let groupHeight: NSCollectionLayoutDimension = columnCount == 1 ? .absolute(44) : .fractionalWidth(0.2)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: groupHeight
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            return section
        }
        collectionView.collectionViewLayout = layout
    }

    private func setupDataSource() {
        let listCellRegistration = UICollectionView
            .CellRegistration<ListCell, Int> { cell, indexPath, identifier in
                cell.label.text = "\(identifier)"
            }
        let textCellRegistration = UICollectionView
            .CellRegistration<TextCell, Int> { cell, indexPath, identifier in
                cell.label.text = "\(identifier)"
                cell.contentView.backgroundColor = .cyan
                cell.contentView.layer.borderColor = UIColor.black.cgColor
                cell.contentView.layer.borderWidth = 1
                cell.contentView.layer.cornerRadius = SectionLayoutKind(rawValue: indexPath.section)! == .grid5 ? 8 : 0
                cell.label.textAlignment = .center
                cell.label.font = UIFont.preferredFont(forTextStyle: .title1)
            }
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(
            collectionView: collectionView
        ) { collectionView, indexPath, identifier -> UICollectionViewCell? in
            return SectionLayoutKind(rawValue: indexPath.section)! == .list ?
            collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: identifier) :
            collectionView.dequeueConfiguredReusableCell(using: textCellRegistration, for: indexPath, item: identifier)
        }
    }

    private func setupInitialData() {
        let itemsPerSection = 10
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
        SectionLayoutKind.allCases.forEach {
            snapshot.appendSections([$0])
            let itemOffset = $0.rawValue * itemsPerSection
            let itemUpperbound = itemOffset + itemsPerSection
            snapshot.appendItems(Array(itemOffset..<itemUpperbound))
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
