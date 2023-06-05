//
//  ListAppearanceViewController.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/05/19.
//

import UIKit

final class ListAppearanceViewController: UIViewController {

    private struct Item: Hashable {
        private let identifier = UUID()
        let text: String
    }

    private struct Section: Hashable {
        private let identifier = UUID()
        let title: String
        let items: [Item]
    }

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
        }
    }

    private var sections: [Section] {
        [
            Section(title: "Title1", items: [Item(text: "Item0"), Item(text: "Item1")]),
            Section(title: "Title2", items: [Item(text: "Item0"), Item(text: "Item1")]),
            Section(title: "Title3", items: [Item(text: "Item0"), Item(text: "Item1"), Item(text: "Item2")]),
            Section(title: "Title4", items: [Item(text: "Item0"), Item(text: "Item1"), Item(text: "Item2")]),
            Section(title: "Title5", items: [Item(text: "Item0"), Item(text: "Item1"), Item(text: "Item2")])
        ]
    }

    static func instantiate() -> ListAppearanceViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! ListAppearanceViewController
        return viewController
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

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
                content.text = item.text
                cell.contentConfiguration = content
                cell.accessories = [.outlineDisclosure()]
            }
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
                var content = cell.defaultContentConfiguration()
                content.text = item.text
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
            }
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
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
        let snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        dataSource.apply(snapshot, animatingDifferences: false)
        sections.forEach {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            let headerItem = Item(text: $0.title)
            sectionSnapshot.append([headerItem])
            sectionSnapshot.append($0.items, to: headerItem)
            sectionSnapshot.expand([headerItem])
            dataSource.apply(sectionSnapshot, to: $0)
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
