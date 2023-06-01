//
//  ListType.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/06/01.
//

import UIKit

enum ListType: Int, CaseIterable {
    case listAppearance
    case grid

    var text: String {
        switch self {
        case .listAppearance:
            return "List Appearance"
        case .grid:
            return "Grid"
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
        }
    }
}
