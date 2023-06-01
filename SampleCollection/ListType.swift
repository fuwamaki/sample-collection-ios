//
//  ListType.swift
//  SampleCollection
//
//  Created by fuwamaki on 2023/06/01.
//

import UIKit

enum ListType: Int, CaseIterable {
    case listAppearance

    var text: String {
        switch self {
        case .listAppearance:
            return "List Appearance"
        }
    }

    func pushViewController(_ navigationController: UINavigationController?) {
        switch self {
        case .listAppearance:
            let viewController = ListAppearanceViewController.instantiate()
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
