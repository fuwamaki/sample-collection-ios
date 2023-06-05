//
//  ListCollectionViewController.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/06/05.
//

import UIKit

final class ListCollectionViewController: UIViewController {

    private struct ItemCollection: Hashable {
        let title: String
        let items: [Item]
    }

    private struct Item: Hashable {
        let title: String
        let category: String
    }

    private var itemCollectionList: [ItemCollection] {
        return [
            ItemCollection(
                title: "The New iPad Pro",
                items: [
                    Item(title: "Bringing Your Apps to the New iPad Pro", category: "Tech Talks"),
                    Item(title: "Designing for iPad Pro and Apple Pencil", category: "Tech Talks")
                ]
            ),
            ItemCollection(
                title: "iPhone and Apple Watch",
                items: [
                    Item(title: "Building Apps for iPhone XS, iPhone XS Max, and iPhone XR", category: "Tech Talks"),
                    Item(title: "Designing for Apple Watch Series 4", category: "Tech Talks"),
                    Item(title: "Developing Complications for Apple Watch Series 4", category: "Tech Talks"),
                    Item(title: "What's New in Core NFC", category: "Tech Talks")
                ]
            ),
            ItemCollection(
                title: "App Store Connect",
                items: [
                    Item(title: "App Store Connect Basics", category: "App Store Connect"),
                    Item(title: "App Analytics Retention", category: "App Store Connect"),
                    Item(title: "App Analytics Metrics", category: "App Store Connect"),
                    Item(title: "App Analytics Overview", category: "App Store Connect"),
                    Item(title: "TestFlight", category: "App Store Connect")
                ]
            ),
            ItemCollection(
                title: "Apps on Your Wrist",
                items: [
                    Item(title: "What's new in watchOS", category: "Conference 2018"),
                    Item(title: "Updating for Apple Watch Series 3", category: "Tech Talks"),
                    Item(title: "Planning a Great Apple Watch Experience", category: "Conference 2017"),
                    Item(title: "News Ways to Work with Workouts", category: "Conference 2018"),
                    Item(title: "Siri Shortcuts on the Siri Watch Face", category: "Conference 2018"),
                    Item(title: "Creating Audio Apps for watchOS", category: "Conference 2018"),
                    Item(title: "Designing Notifications", category: "Conference 2018")
                ]
            ),
            ItemCollection(
                title: "Speaking with Siri",
                items: [
                    Item(title: "Introduction to Siri Shortcuts", category: "Conference 2018"),
                    Item(title: "Building for Voice with Siri Shortcuts", category: "Conference 2018"),
                    Item(title: "What's New in SiriKit", category: "Conference 2017"),
                    Item(title: "Making Great SiriKit Experiences", category: "Conference 2017"),
                    Item(title: "Increase Usage of You App With Proactive Suggestions", category: "Conference 2018")
                ]
            )
        ]
    }

    @IBOutlet private weak var collectionView: UICollectionView!

    static func instantiate() -> ListCollectionViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! ListCollectionViewController
        return viewController
    }

    private var dataSource: UICollectionViewDiffableDataSource<ItemCollection, Item>!
    private var snapshot: NSDiffableDataSourceSnapshot<ItemCollection, Item>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        setupDataSource()
        setupInitialData()
    }

    private func setupCollectionViewLayout() {
        let sectionProvider = { (
            sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment
        ) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupFractionalWidth = CGFloat(
                layoutEnvironment.container.effectiveContentSize.width > 500 ? 0.425 : 0.85
            )
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(groupFractionalWidth),
                heightDimension: .absolute(250)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            
            let titleSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: "title_kind",
                alignment: .top
            )
            section.boundarySupplementaryItems = [titleSupplementary]
            return section
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider,
            configuration: config
        )
        collectionView.collectionViewLayout = layout
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
                var content = cell.defaultContentConfiguration()
                content.text = "\(item)"
                cell.contentConfiguration = content
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.gray.cgColor
        }
        dataSource = UICollectionViewDiffableDataSource<ItemCollection, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, identifier in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: identifier
            )
        }
        let supplementaryRegistration = UICollectionView
            .SupplementaryRegistration<TitleSupplementaryView>(
                elementKind: "title_kind"
            ) { [unowned self] supplementaryView, string, indexPath in
                if let snapshot = self.snapshot {
                    let videoCategory = snapshot.sectionIdentifiers[indexPath.section]
                    supplementaryView.label.text = videoCategory.title
                }
            }
        dataSource.supplementaryViewProvider = { [unowned self] view, kind, indexPath in
            return self.collectionView
                .dequeueConfiguredReusableSupplementary(
                    using: supplementaryRegistration,
                    for: indexPath
                )
        }
    }

    private func setupInitialData() {
        snapshot = NSDiffableDataSourceSnapshot<ItemCollection, Item>()
        itemCollectionList.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
