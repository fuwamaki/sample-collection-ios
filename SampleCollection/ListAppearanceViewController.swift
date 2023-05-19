//
//  ListAppearanceViewController.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/05/19.
//

import UIKit

final class ListAppearanceViewController: UIViewController {

    private struct Item: Hashable {
        let title: String?
        private let identifier = UUID()
    }

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
        }
    }

    static func instantiate() -> ListAppearanceViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! ListAppearanceViewController
        return viewController
    }

    private var dataSource: UICollectionViewDiffableDataSource<Int, Item>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupCollectionViewLayout()
        setupDataSource()
        setupInitialData()
    }

    private func setupCollectionViewLayout() {
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.headerMode = .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }

    private func setupDataSource() {
        let headerRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
                var content = cell.defaultContentConfiguration()
                content.text = item.title
                cell.contentConfiguration = content
                cell.accessories = [.outlineDisclosure()]
            }
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
                var content = cell.defaultContentConfiguration()
                content.text = item.title
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
            }
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: indexPath.item == 0 ? headerRegistration : cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    private func setupInitialData() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        let sections = Array(0..<5)
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        for section in sections {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            let headerItem = Item(title: "Section \(section)")
            sectionSnapshot.append([headerItem])
            let items = Array(0..<3).map { Item(title: "Item \($0)") }
            sectionSnapshot.append(items, to: headerItem)
            sectionSnapshot.expand([headerItem])
            dataSource.apply(sectionSnapshot, to: section)
        }
    }
}

// MARK: UICollectionViewDelegate
extension ListAppearanceViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
