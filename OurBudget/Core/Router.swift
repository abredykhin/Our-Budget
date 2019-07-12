//
//  Router.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/8/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class Router {

    var viewControllers: [NavigationOption: UIViewController] = [:]

    init() {
        configureInitialRootViewController()
    }

    func go(to navigationOption: NavigationOption) {
        if let cachedViewController = viewControllers[navigationOption] {
            changeRootViewController(to: cachedViewController, animated: false)
        } else {
            let targetViewController = navigationOption.initialViewController
            viewControllers[navigationOption] = targetViewController
            changeRootViewController(to: targetViewController, animated: false)
        }
    }

    func configureInitialRootViewController() {
        let entryVC = StoryboardScene.Entry.initialScene.instantiate()
        changeRootViewController(to: entryVC, animated: false)
    }

    func changeRootViewController(to storyboardType: StoryboardType.Type, animated: Bool = true) {
        guard let newController = storyboardType.storyboard.instantiateInitialViewController() else {
            print("Unable to instantiateInitialViewController for \(storyboardType)")
            return
        }

        changeRootViewController(to: newController, animated: animated)
    }

    func changeRootViewController(to viewController: UIViewController, animated: Bool = true) {
        print("Changing root view controller to \(viewController)")

        let window = UIApplication.shared.keyWindow
        var transitionOptions = UIWindow.TransitionOptions()
        transitionOptions.duration = animated ? 0.2 : 0

        window?.setRootViewController(viewController, options: transitionOptions)
    }

    func share(on viewController: UIViewController?, sourceView: UIView, sourceRect: CGRect, items: [Any]) {
        guard let viewController = viewController else {
            print("Cannot present share on nil viewController")
            return
        }

        let activityViewController = UIActivityViewController(activityItems: items,
                                                              applicationActivities: nil)

        activityViewController.popoverPresentationController?.sourceView = sourceView
        activityViewController.popoverPresentationController?.sourceRect = sourceRect

        viewController.present(activityViewController, animated: true)
    }
}
