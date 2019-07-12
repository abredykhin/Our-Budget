//
//  ViewControllerContainer.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/10/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import UIKit

protocol ViewControllerContainer {
    associatedtype ContainerView: UIView
}

extension ViewControllerContainer where Self: UIViewController {
    func embed(_ controller: UIViewController, in view: ContainerView) {
        controller.view.removeFromSuperview()
        controller.removeFromParent()

        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        controller.didMove(toParent: self)
    }
}

extension ViewControllerContainer where Self: UIViewController, ContainerView: ControllerTableViewCell {
    func embed(_ controller: UIViewController, in view: ContainerView, configure: (UIView) -> Void = { _ in }) {
        controller.view.removeFromSuperview()
        controller.removeFromParent()

        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        let container = view.makeContainer(configure: configure)
        container.addSubview(controller.view)

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: container.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])

        controller.didMove(toParent: self)
    }
}

extension ViewControllerContainer where Self: UIViewController, ContainerView: ControllerCollectionViewCell {
    func embed(_ controller: UIViewController, in view: ContainerView, configure: (UIView) -> Void = { _ in }) {
        controller.view.removeFromSuperview()
        controller.removeFromParent()

        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        let container = view.makeContainer(configure: configure)
        container.addSubview(controller.view)

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: container.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])

        controller.didMove(toParent: self)
    }
}

final class ControllerTableViewCell: UITableViewCell {
    static let reuseId = String(describing: ControllerTableViewCell.self)
    private weak var container: UIView?

    func makeContainer(configure: (UIView) -> Void = { _ in }) -> UIView {
        backgroundColor = .clear
        self.container?.removeFromSuperview()
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.addSubview(container)
        configure(container)
        self.container = container
        return container
    }
}

final class ControllerCollectionViewCell: UICollectionViewCell {
    static let reuseId = String(describing: ControllerCollectionViewCell.self)
    private weak var container: UIView?

    func makeContainer(configure: (UIView) -> Void = { _ in }) -> UIView {
        backgroundColor = .clear
        self.container?.removeFromSuperview()
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.addSubview(container)
        configure(container)
        self.container = container
        return container
    }
}
