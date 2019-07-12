//
//  NavigationOption.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/8/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation
import UIKit

enum NavigationOption: String, CaseIterable {
    case home
}

extension NavigationOption {

    var menuDisplayName: String {
        switch self {
        case .home: return "HOME"
        }
    }

    var headerDisplayName: String {
        switch self {
        default: return menuDisplayName
        }
    }

    var initialViewController: UIViewController {
        switch self {
        case .home: return StoryboardScene.Main.initialScene.instantiate()
        }
    }

    static var `default`: NavigationOption {
        return .home
    }
}
