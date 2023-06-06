//
//  ReorderListViewController.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/06/06.
//

import UIKit

final class ReorderListViewController: UIViewController {

    typealias Section = Emoji.Category

    struct Item: Hashable {
        let title: String
        let emoji: Emoji
        init(emoji: Emoji, title: String) {
            self.emoji = emoji
            self.title = title
        }
        private let identifier = UUID()
    }

    private enum ReorderingMethod: CustomStringConvertible {
        case finalSnapshot
        case collectionDifference

        var description: String {
            switch self {
            case .collectionDifference: return "Collection Difference"
            case .finalSnapshot: return "Final Snapshot Items"
            }
        }
    }

    @IBOutlet private weak var collectionView: UICollectionView!

    static func instantiate() -> ReorderListViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! ReorderListViewController
        return viewController
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var reorderingMethod: ReorderingMethod = .collectionDifference
    lazy var backingStore: [Section: [Item]] = { initialBackingStore() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItem()
        setupCollectionViewLayout()
        setupDataSource()
        applySnapshotsFromBackingStore()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            if let coordinator = transitionCoordinator {
                coordinator.animate(alongsideTransition: { context in
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                }) { [unowned self] context in
                    if context.isCancelled {
                        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    }
                }
            } else {
                collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }
    }

    private func setupNavItem() {
        func createMenu() -> UIMenu {
            let refreshAction = UIAction(
                title: "Reload backingStore",
                image: UIImage(systemName: "arrow.counterclockwise")
            ) { [weak self] _ in
                guard let self = self else { return }
                self.applySnapshotsFromBackingStore(animated: true)
            }
            let restoreAction = UIAction(
                title: "Reload initialStore",
                image: UIImage(systemName: "arrow.counterclockwise")
            ) { [weak self] _ in
                guard let self = self else { return }
                self.applyInitialBackingStore(animated: true)
            }
            let finalSnapshotAction = UIAction(
                title: String(describing: ReorderingMethod.finalSnapshot),
                image: UIImage(systemName: "function")) { [weak self] action in
                    guard let self = self else { return }
                    self.reorderingMethod = .finalSnapshot
                    if let barButtonItem = action.sender as? UIBarButtonItem {
                        barButtonItem.menu = createMenu()
                    }
                }
            let collectionDifferenceAction = UIAction(
                title: String(describing: ReorderingMethod.collectionDifference),
                image: UIImage(systemName: "function")) { [weak self] action in
                    guard let self = self else { return }
                    self.reorderingMethod = .collectionDifference
                    if let barButtonItem = action.sender as? UIBarButtonItem {
                        barButtonItem.menu = createMenu()
                    }
                }
            if self.reorderingMethod == .collectionDifference {
                collectionDifferenceAction.state = .on
            } else if self.reorderingMethod == .finalSnapshot {
                finalSnapshotAction.state = .on
            }
            let reorderingMethodMenu = UIMenu(
                title: "",
                options: .displayInline,
                children: [finalSnapshotAction, collectionDifferenceAction]
            )
            let menu = UIMenu(title: "", children: [refreshAction, restoreAction, reorderingMethodMenu])
            return menu
        }
        let navItem = UIBarButtonItem(image: UIImage(systemName: "gear"), menu: createMenu())
        navigationItem.rightBarButtonItem = navItem
    }

    private func setupCollectionViewLayout() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
//        let layout = UICollectionViewCompositionalLayout {
//            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
//            guard let sectionLayoutKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }
//            let columnCount = sectionLayoutKind.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)
//            let itemSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0/CGFloat(columnCount)),
//                heightDimension: .fractionalHeight(1.0)
//            )
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
//            let groupHeight: NSCollectionLayoutDimension = columnCount == 1 ? .absolute(44) : .fractionalWidth(0.2)
//            let groupSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: groupHeight
//            )
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//            let section = NSCollectionLayoutSection(group: group)
//            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
//            return section
//        }
//        collectionView.collectionViewLayout = layout
    }

    private func setupDataSource() {
        let listCellRegistration = UICollectionView
            .CellRegistration<ListCell, Int> { cell, indexPath, identifier in
                cell.label.text = "\(identifier)"
            }
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, Emoji> { cell, indexPath, emoji in
                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = emoji.text
                contentConfiguration.secondaryText = String(describing: emoji.category)
                cell.contentConfiguration = contentConfiguration
                cell.accessories = [.disclosureIndicator(), .reorder(displayed: .always)]
            }
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, item -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item.emoji
            )
        }
        dataSource.reorderingHandlers.canReorderItem = { item in return true }
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            guard let self = self else { return }
            if self.reorderingMethod == .collectionDifference {
                for sectionTransaction in transaction.sectionTransactions {
                    let sectionIdentifier = sectionTransaction.sectionIdentifier
                    if let previousSectionItems = self.backingStore[sectionIdentifier],
                       let updatedSectionItems = previousSectionItems.applying(sectionTransaction.difference) {
                        self.backingStore[sectionIdentifier] = updatedSectionItems
                    }
                }
            } else if self.reorderingMethod == .finalSnapshot {
                for sectionTransaction in transaction.sectionTransactions {
                    let sectionIdentifier = sectionTransaction.sectionIdentifier
                    self.backingStore[sectionIdentifier] = sectionTransaction.finalSnapshot.items
                }
            }
        }
    }

    func initialBackingStore() -> [Section: [Item]] {
        var allItems = [Section: [Item]]()
        for category in Emoji.Category.allCases.reversed() {
            let items = category.emojis.map { Item(emoji: $0, title: String(describing: category)) }
            allItems[category] = items
        }
        return allItems
    }

    func applyInitialBackingStore(animated: Bool = false) {
        for (section, items) in initialBackingStore() {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            sectionSnapshot.append(items)
            dataSource.apply(sectionSnapshot, to: section, animatingDifferences: animated)
        }
    }

    func applySnapshotsFromBackingStore(animated: Bool = false) {
        for (section, items) in backingStore {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            sectionSnapshot.append(items)
            dataSource.apply(sectionSnapshot, to: section, animatingDifferences: animated)
        }
    }
}
