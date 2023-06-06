//
//  MainViewController.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/05/19.
//

import UIKit

class MainViewController: UIViewController {

    private enum Section {
        case main
    }

    private enum ListType: Int, CaseIterable {
        case listAppearance
        case grid
        case insetItemsGrid
        case twoColumnGrid
        case sectionHeaderFooter
        case pinnedSectionHeaderFooter
        case listCollection
        case distinctSection

        var text: String {
            switch self {
            case .listAppearance:
                return "List Appearance"
            case .grid:
                return "Grid"
            case .insetItemsGrid:
                return "Inset Items Grid"
            case .twoColumnGrid:
                return "Two Column Grid"
            case .sectionHeaderFooter:
                return "Section Header Footer"
            case .pinnedSectionHeaderFooter:
                return "Pinned Section Header Footer"
            case .listCollection:
                return "List Collection"
            case .distinctSection:
                return "Distinct Section"
            }
        }

        func pushViewController(_ navigationController: UINavigationController?) {
            switch self {
            case .listAppearance:
                let viewController = ListAppearanceViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            case .grid:
                let viewController = GridViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            case .insetItemsGrid:
                let viewController = InsetItemsGridViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            case .twoColumnGrid:
                let viewController = TwoColumnGridViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            case .sectionHeaderFooter:
                let viewController = SectionHeaderFooterViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            case .pinnedSectionHeaderFooter:
                let viewController = PinnedSectionHeaderFooterViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            case .listCollection:
                let viewController = ListCollectionViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            case .distinctSection:
                let viewController = DistinctSectionViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, ListType>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupCollectionViewLayout()
        setupDataSource()
        setupInitialData()
    }

    private func setupCollectionViewLayout() {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView.collectionViewLayout = layout
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, ListType> { cell, indexPath, item in
                var content = cell.defaultContentConfiguration()
                content.text = item.text
                cell.contentConfiguration = content
            }
        dataSource = UICollectionViewDiffableDataSource<Section, ListType>(
            collectionView: collectionView
        ) { collectionView, indexPath, identifier in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: identifier
            )
        }
    }

    private func setupInitialData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ListType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(ListType.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        ListType(rawValue: indexPath.row)?.pushViewController(navigationController)
    }
}
