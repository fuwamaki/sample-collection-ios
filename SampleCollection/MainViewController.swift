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
