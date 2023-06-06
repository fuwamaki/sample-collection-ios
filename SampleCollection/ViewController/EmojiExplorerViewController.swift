//
//  EmojiExplorerViewController.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/06/06.
//

import UIKit

class EmojiExplorerViewController: UIViewController {

    enum Section: Int, Hashable, CaseIterable, CustomStringConvertible {
        case recents
        case outline
        case list

        var description: String {
            switch self {
            case .recents: return "Recents"
            case .outline: return "Outline"
            case .list: return "List"
            }
        }
    }

    struct Item: Hashable {
        let title: String?
        let emoji: Emoji?
        let hasChildren: Bool
        init(emoji: Emoji? = nil, title: String? = nil, hasChildren: Bool = false) {
            self.emoji = emoji
            self.title = title
            self.hasChildren = hasChildren
        }
        private let identifier = UUID()
    }

    @IBOutlet private weak var collectionView: UICollectionView!

    static func instantiate() -> EmojiExplorerViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! EmojiExplorerViewController
        return viewController
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var starredEmojis = Set<Item>()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        setupCollectionViewLayout()
        setupDataSource()
        setupInitialData()
    }

    private func setupCollectionViewLayout() {
        let sectionProvider = {
            [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            guard let sectionKind = Section(rawValue: sectionIndex) else { fatalError() }
            let section: NSCollectionLayoutSection
            if sectionKind == .recents {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.28),
                    heightDimension: .fractionalWidth(0.2)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            } else if sectionKind == .outline {
                section = NSCollectionLayoutSection.list(using: .init(appearance: .sidebar), layoutEnvironment: layoutEnvironment)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
            } else if sectionKind == .list {
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.leadingSwipeActionsConfigurationProvider = { [weak self] (indexPath: IndexPath) in
                    guard let self = self else { return nil }
                    guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
                    return self.leadingSwipeActionConfigurationForListCellItem(item)
                }
                section = NSCollectionLayoutSection.list(
                    using: configuration,
                    layoutEnvironment: layoutEnvironment
                )
            } else {
                fatalError("Unknown section!")
            }
            return section
        }
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func setupDataSource() {
        let gridCellRegistration = UICollectionView
            .CellRegistration<UICollectionViewCell, Emoji> { cell, indexPath, emoji in
                var content = UIListContentConfiguration.cell()
                content.text = emoji.text
                content.textProperties.font = .boldSystemFont(ofSize: 38)
                content.textProperties.alignment = .center
                content.directionalLayoutMargins = .zero
                cell.contentConfiguration = content
                var background = UIBackgroundConfiguration.listPlainCell()
                background.cornerRadius = 8
                background.strokeColor = .systemGray3
                background.strokeWidth = 1.0 / cell.traitCollection.displayScale
                cell.backgroundConfiguration = background
            }
        let listCellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, indexPath, item in
                guard let self = self, let emoji = item.emoji else { return }
                var content = UIListContentConfiguration.valueCell()
                content.text = emoji.text
                content.secondaryText = String(describing: emoji.category)
                cell.contentConfiguration = content
                cell.accessories = self.accessoriesForListCellItem(item)
            }
        let outlineHeaderCellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
                var content = cell.defaultContentConfiguration()
                content.text = title
                cell.contentConfiguration = content
                cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
            }
        let outlineCellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, Emoji> { cell, indexPath, emoji in
                var content = cell.defaultContentConfiguration()
                content.text = emoji.text
                content.secondaryText = emoji.title
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
            }
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            switch section {
            case .recents:
                return collectionView.dequeueConfiguredReusableCell(using: gridCellRegistration, for: indexPath, item: item.emoji)
            case .list:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: item)
            case .outline:
                if item.hasChildren {
                    return collectionView.dequeueConfiguredReusableCell(using: outlineHeaderCellRegistration, for: indexPath, item: item.title!)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: outlineCellRegistration, for: indexPath, item: item.emoji)
                }
            }
        }
    }

    private func setupInitialData() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        let recentItems = Emoji.Category.recents.emojis.map { Item(emoji: $0) }
        var recentsSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        recentsSnapshot.append(recentItems)
        dataSource.apply(recentsSnapshot, to: .recents, animatingDifferences: false)
        var allSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        var outlineSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        for category in Emoji.Category.allCases where category != .recents {
            let allSnapshotItems = category.emojis.map { Item(emoji: $0) }
            allSnapshot.append(allSnapshotItems)
            let rootItem = Item(title: String(describing: category), hasChildren: true)
            outlineSnapshot.append([rootItem])
            let outlineItems = category.emojis.map { Item(emoji: $0) }
            outlineSnapshot.append(outlineItems, to: rootItem)
        }
        dataSource.apply(recentsSnapshot, to: .recents, animatingDifferences: false)
        dataSource.apply(allSnapshot, to: .list, animatingDifferences: false)
        dataSource.apply(outlineSnapshot, to: .outline, animatingDifferences: false)
        for _ in 0..<5 {
            if let item = allSnapshot.items.randomElement() {
                self.starredEmojis.insert(item)
            }
        }
    }

    func accessoriesForListCellItem(_ item: Item) -> [UICellAccessory] {
        let isStarred = self.starredEmojis.contains(item)
        var accessories = [UICellAccessory.disclosureIndicator()]
        if isStarred {
            let star = UIImageView(image: UIImage(systemName: "star.fill"))
            accessories.append(.customView(configuration: .init(customView: star, placement: .trailing())))
        }
        return accessories
    }

    func leadingSwipeActionConfigurationForListCellItem(_ item: Item) -> UISwipeActionsConfiguration? {
        let isStarred = self.starredEmojis.contains(item)
        let starAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }
            if isStarred {
                self.starredEmojis.remove(item)
            } else {
                self.starredEmojis.insert(item)
            }
            if let currentIndexPath = self.dataSource.indexPath(for: item) {
                if let cell = self.collectionView.cellForItem(at: currentIndexPath) as? UICollectionViewListCell {
                    UIView.animate(withDuration: 0.2) {
                        cell.accessories = self.accessoriesForListCellItem(item)
                    }
                }
            }
            completion(true)
        }
        starAction.image = UIImage(systemName: isStarred ? "star.slash" : "star.fill")
        starAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [starAction])
    }
}

// MARK: UICollectionViewDelegate
extension EmojiExplorerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let emoji = self.dataSource.itemIdentifier(for: indexPath)?.emoji else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        let detailViewController = EmojiDetailViewController(with: emoji)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
