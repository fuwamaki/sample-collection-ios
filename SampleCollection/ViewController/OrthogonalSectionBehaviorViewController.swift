//
//  OrthogonalSectionBehaviorViewController.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/06/06.
//

import UIKit

final class OrthogonalSectionBehaviorViewController: UIViewController {

    private enum Section {
        case main
    }

    enum SectionKind: Int, CaseIterable {
        case continuous
        case continuousGroupLeadingBoundary
        case paging
        case groupPaging
        case groupPagingCentered
        case none

        func orthogonalScrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
            switch self {
            case .none:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.none
            case .continuous:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuous
            case .continuousGroupLeadingBoundary:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
            case .paging:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.paging
            case .groupPaging:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPaging
            case .groupPagingCentered:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
            }
        }
    }

    @IBOutlet private weak var collectionView: UICollectionView!

    static func instantiate() -> OrthogonalSectionBehaviorViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! OrthogonalSectionBehaviorViewController
        return viewController
    }

    static let headerElementKind = "header-element-kind"
    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        setupDataSource()
        setupInitialData()
    }

    private func setupCollectionViewLayout() {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
                    fatalError("unknown section kind")
                }
                let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.7),
                    heightDimension: .fractionalHeight(1.0))
                )
                leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(0.5))
                )
                trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                let trailingGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.3),
                        heightDimension: .fractionalHeight(1.0)
                    ),
                    subitems: [trailingItem]
                )
                let orthogonallyScrolls = sectionKind.orthogonalScrollingBehavior() != .none
                let containerGroupFractionalWidth = orthogonallyScrolls ? CGFloat(0.85) : CGFloat(1.0)
                let containerGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(containerGroupFractionalWidth),
                        heightDimension: .fractionalHeight(0.4)
                    ),
                    subitems: [leadingItem, trailingGroup]
                )
                let section = NSCollectionLayoutSection(group: containerGroup)
                section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior()
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(44)
                    ),
                    elementKind: OrthogonalSectionBehaviorViewController.headerElementKind,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            },
            configuration: config
        )
        collectionView.collectionViewLayout = layout
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView
            .CellRegistration<TextCell, Int> { cell, indexPath, identifier in
                cell.label.text = "\(indexPath.section), \(indexPath.item)"
                cell.contentView.backgroundColor = .cyan
                cell.contentView.layer.borderColor = UIColor.black.cgColor
                cell.contentView.layer.borderWidth = 1
                cell.contentView.layer.cornerRadius = 8
                cell.label.textAlignment = .center
                cell.label.font = UIFont.preferredFont(forTextStyle: .title1)
            }
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(
            collectionView: collectionView
        ) { collectionView, indexPath, identifier -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: identifier
            )
        }
        let supplementaryRegistration = UICollectionView
            .SupplementaryRegistration<TitleSupplementaryView>(
                elementKind: OrthogonalSectionBehaviorViewController.headerElementKind
            ) { supplementaryView, string, indexPath in
                let sectionKind = SectionKind(rawValue: indexPath.section)!
                supplementaryView.label.text = "." + String(describing: sectionKind)
            }
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }
    }

    private func setupInitialData() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var identifierOffset = 0
        let itemsPerSection = 18
        SectionKind.allCases.forEach {
            snapshot.appendSections([$0.rawValue])
            let maxIdentifier = identifierOffset + itemsPerSection
            snapshot.appendItems(Array(identifierOffset..<maxIdentifier))
            identifierOffset += itemsPerSection
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
