//
//  LastTransactions.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/11/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import UIKit
import FirebaseFirestore
import RxSwift

private let cellPadding: CGFloat = 16
private let lowHitWidth = 212
private let lowHitHeight = 164
private let moderateHitWidth = 188
private let moderateHitHeight = 148
private let highHitWidth = 148
private let highHitHeight = 109

class RecentTransactionsViewController : UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private let viewModel = RecentTransactionsViewModel(firestore: Firestore.firestore())
    private let disposeBag = DisposeBag()
    private var transactionCount = 0
    private var transactions: [RecentTransaction]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.transactions.emit(onNext: { [weak self] in self?.transactions = $0 }).disposed(by: disposeBag)
    }
}

extension RecentTransactionsViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO:
    }
}

extension RecentTransactionsViewController : UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactionCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "recentTransactionsCell", for: indexPath)

        guard let cell = collectionCell as? RecentTransactionsCell else {
            fatalError("Unable to dequeue ControllerCollectionViewCell")
        }

        guard let transactions = transactions else { return cell }

        cell.configure(transactions[indexPath.row])
        return cell
    }
}

extension RecentTransactionsViewController: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let transactions = transactions else { fatalError("Cannot display transaction") }

        switch transactions[indexPath.row].budgetHit {
        case 0 ... 20:
            return CGSize(width: lowHitWidth, height: lowHitHeight)
        case 21 ... 49:
            return CGSize(width: moderateHitWidth, height: moderateHitHeight)
        case 50 ... 100:
            return CGSize(width: highHitWidth, height: highHitHeight)
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

