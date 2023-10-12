//
//  SimpleListViewController.swift
//  SampleCollection
//
//  Created by yusaku maki on 2023/10/12.
//

import UIKit

final class SimpleListViewController: UIViewController {

    private enum Section {
        case main
    }

    @IBOutlet private weak var collectionView: UICollectionView!

    static func instantiate() -> SimpleListViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! SimpleListViewController
        return viewController
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>!

    override func viewDidLoad() {
        super.viewDidLoad()
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
            .CellRegistration<UICollectionViewListCell, Int> { cell, indexPath, item in
                var content = cell.defaultContentConfiguration()
                content.text = "\(item)"
                cell.contentConfiguration = content
            }
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<100))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
