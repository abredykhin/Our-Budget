//
//  FirstViewController.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 6/10/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import UIKit

import FirebaseFunctions
import FirebaseFirestore
import FirebaseUI
import LinkKit
import RxCocoa
import RxSwift

class OverviewViewController: UIViewController, ViewControllerContainer {
    typealias ContainerView = ControllerCollectionViewCell

    @IBOutlet weak var collectionView: UICollectionView!    
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    private let cellPadding: CGFloat = 16
    private var controllers: [IndexPath: UIViewController] = [:]

    private lazy var viewModel: OverviewViewModel = OverviewViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        collectionView.register(ControllerCollectionViewCell.self,
                                forCellWithReuseIdentifier: ControllerCollectionViewCell.reuseId)
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOpacity = 1
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 4)
        collectionView.layer.shadowRadius = 16
        collectionView.backgroundColor = .clear

        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshAll(_:)), for: .valueChanged)
        refreshControl.tintColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }

    @objc private func refreshAll(_ sender: Any) {
        reloadUI()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl.endRefreshing()
        }
    }

    private func reloadUI() {
        for (_, controller) in controllers {
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
        controllers.removeAll()
        collectionView.reloadData()
    }
}

extension OverviewViewController: UICollectionViewDataSource {

    private func configureCellContainer(_ container: UIView) {
        guard let superview = container.superview else { return }

        container.clipsToBounds = true
        container.cornerRadius = 8
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            container.topAnchor.constraint(equalTo: superview.topAnchor),
            container.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.state.numSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ControllerCollectionViewCell.reuseId, for: indexPath)

        guard let cell = collectionCell as? ControllerCollectionViewCell else {
            fatalError("Unable to dequeue ControllerCollectionViewCell")
        }

        if let controller = controllers[indexPath] {
            embed(controller, in: cell, configure: configureCellContainer)
        } else {
            switch viewModel.state.section(at: indexPath) {
            case .balances?:
                let controller = StoryboardScene.Balances.initialScene.instantiate()
                embed(controller, in: cell, configure: configureCellContainer)
                controllers[indexPath] = controller
            case .budget?:
                let controller = StoryboardScene.Budget.initialScene.instantiate()
                embed(controller, in: cell, configure: configureCellContainer)
                controllers[indexPath] = controller
            case nil:
                break
            default:
                break
            }
        }

        return cell
    }
}

extension OverviewViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths where controllers[indexPath] == nil {
            switch viewModel.state.section(at: indexPath) {
            case .balances?:
                let controller = StoryboardScene.Balances.initialScene.instantiate()
                _ = controller.view
                controllers[indexPath] = controller
            case .budget?:
                let controller = StoryboardScene.Budget.initialScene.instantiate()
                _ = controller.view
                controllers[indexPath] = controller
            case nil:
                break
            default:
                break
            }
        }
    }
}

extension OverviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewWidth = collectionView.bounds.width - cellPadding * 2
        let width = viewWidth

        switch viewModel.state.section(at: indexPath) {
        case .balances?:
            return CGSize(width: width, height: 250)
        case .budget?:
            return CGSize(width: width, height: 200)
        case nil:
            return .zero
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellPadding
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellPadding
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellPadding, left: cellPadding, bottom: 0, right: cellPadding)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 0)
    }
}
