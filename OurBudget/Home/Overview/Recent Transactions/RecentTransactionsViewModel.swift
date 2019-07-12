//
//  LastTransactionsViewModel.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/11/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore
import RxFirebaseFirestore

class RecentTransactionsViewModel {
    private let disposeBag = DisposeBag()
    private let _transactions = PublishRelay<[RecentTransaction]>()
    let transactions: Signal<[RecentTransaction]>

    init(firestore: Firestore) {
        self.transactions = _transactions.asSignal()

        Observable.combineLatest(recentTransactions(firestore), getMainBudget(firestore))
            .subscribe(
                onNext: { [weak self] transactions, budget in
                    let recentTransactions = transactions
                        .map { (tr: Transaction) -> RecentTransaction in
                            let hit = tr.amount * 100.0 / budget.dailyLimit
                            return RecentTransaction(amount: tr.amount.presentBalanceValue(), name: tr.name, budgetHit: Int(hit))
                        }
                        .sorted { $0.budgetHit > $1.budgetHit}

                    self?._transactions.accept(recentTransactions)
                },
                onError: { error in
                    print("Error fetching recent transactions: \(error)")
                }
            ).disposed(by: disposeBag)
    }

    private func recentTransactions(_ firestore: Firestore) -> Observable<[Transaction]> {
        let dayAgo = Date().dayAgo.format()

        return firestore
                .collection(Constants.Firestore.banksCollection)
                .rx
                .getDocuments()
                .flatMap { Observable.from($0.documents)}
                .flatMap { snapshot in
                    firestore
                        .collection(Constants.Firestore.banksCollection)
                        .document(snapshot.documentID)
                        .collection(Constants.Firestore.transactionsCollection)
                        .order(by: Constants.Firestore.Transaction.date)
                        .whereField(Constants.Firestore.Transaction.date, isGreaterThanOrEqualTo: dayAgo)
                        .rx
                        .getDocuments()
                }
                .flatMap { Observable.from($0.documents)}
                .flatMap { Observable.just(Transaction.init(dictionary: $0.data())) }
                .toArray()
    }

    private func getMainBudget(_ firestore: Firestore) -> Observable<Budget> {
        return firestore
            .collection(Constants.Firestore.budgetsCollection)
            .whereField(Constants.Firestore.Budget.name, isEqualTo: Constants.Firestore.mainBudget)
            .rx
            .getDocuments()
            .flatMap { Observable.from($0.documents)}
            .take(1)
            .map { Budget.init(dictionary: $0.data()) }
    }
}
