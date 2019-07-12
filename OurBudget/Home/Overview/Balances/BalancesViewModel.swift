//
//  BalancesViewModel.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/8/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation
import Firebase
import RxFirebaseFirestore
import RxFirebaseAuthentication
import RxFirebaseFunctions
import RxSwift
import RxCocoa

class BalancesViewModel {
    private let disposeBag = DisposeBag()
    private let functions: Functions
    private let firestore: Firestore

    private let cashBalanceRelay = BehaviorRelay<Double>(value: 0.00)
    private let creditBalanceRelay = BehaviorRelay<Double>(value: 0.00)
    private let netBalanceRelay = BehaviorRelay<String>(value: "$0.00")
    private let retirementBalanceRelay = BehaviorRelay<Double>(value: 0.00)
    private let mortgageBalanceRelay = BehaviorRelay<Double>(value: 0.00)
    private let savingsBalanceRelay = BehaviorRelay<Double>(value: 0.00)

    lazy var cashBalance = cashBalanceRelay.map { value in value.presentBalanceValue() }.asSignal(onErrorJustReturn: "$0.00")
    lazy var creditBalance = creditBalanceRelay.map { value in value.presentBalanceValue() }.asSignal(onErrorJustReturn: "$0.00")
    lazy var netBalance = netBalanceRelay.asSignal(onErrorJustReturn: "$0.00")
    lazy var retirementBalance = retirementBalanceRelay
        .map { value in value.presentBalanceValue() }
        .asSignal(onErrorJustReturn: "$0.00")
    lazy var mortgageBalance = mortgageBalanceRelay
        .map { value in value.presentBalanceValue() }
        .asSignal(onErrorJustReturn: "$0.00")
    lazy var savingsBalance = savingsBalanceRelay
        .map { value in value.presentBalanceValue() }
        .asSignal(onErrorJustReturn: "$0.00")

    init(functions: Functions, firestore: Firestore) {
        self.firestore = firestore
        self.functions = functions

        Driver.combineLatest(cashBalanceRelay.asDriver(), creditBalanceRelay.asDriver())
            .map { cash, credit in return cash - credit }
            .map { net in net.presentBalanceValue() }
            .drive(netBalanceRelay)
            .disposed(by: disposeBag)
        updateAllBalances()
    }

    private func updateAllBalances() {
        getBalances(accountType: Constants.Firestore.Account.AccountType.depository,
                    accountSubtype: Constants.Firestore.Account.AccountType.Subtype.checking,
                    relay: cashBalanceRelay)

        getBalances(accountType: Constants.Firestore.Account.AccountType.credit,
                    accountSubtype: Constants.Firestore.Account.AccountType.Subtype.creditCard,
                    relay: creditBalanceRelay)

        // TODO: get balances for the rest
    }

    private func getBalances(accountType: String, accountSubtype: String, relay: BehaviorRelay<Double>) {
        firestore
            .collection(Constants.Firestore.banksCollection)
            .rx
            .getDocuments()
            .flatMap { Observable.from($0.documents)}
            .flatMap { [self] snapshot in
                self.firestore
                    .collection(Constants.Firestore.banksCollection)
                    .document(snapshot.documentID)
                    .collection(Constants.Firestore.accountsCollection)
                    .whereField(Constants.Firestore.Account.type, isEqualTo: accountType)
                    .rx
                    .getDocuments()
            }
            .flatMap { Observable.from($0.documents)}
            .reduce(0.00, accumulator: { acc, snapshot in
                return acc + Account.init(dictionary: snapshot.data()).balances.current
            })
            .subscribe(
                onNext: { totalBalance in
                    relay.accept(totalBalance)
                },
                onError: { error in
                    print("Error fetching accounts: \(error)")
                }
            ).disposed(by: disposeBag)
    }

    private func listenToTransactions() {
        getBanks()
            .flatMap { [self] bank in
                self.firestore
                    .collection(Constants.Firestore.banksCollection)
                    .document(bank.id)
                    .collection(Constants.Firestore.accountsCollection)
                    .rx
                    .getDocuments()
            }
            .flatMap { Observable.from($0.documents)}
            .map { Account.init(dictionary: $0.data()) }
            .subscribe(
                onNext: { [weak self] account in
                    guard let self = self else { return }
                    //                    self.listenToAccountTransactions(bankId:  accountId: account.id)
                },
                onError: { error in
                    print("Error listening to bank updates: \(error)")
            }
            ).disposed(by: disposeBag)
    }

    private func getBanks() -> Observable<Bank> {
        return firestore.collection(Constants.Firestore.banksCollection)
            .rx
            .getDocuments()
            .flatMap { Observable.from($0.documents)}
            .map { Bank.init(dictionary: $0.data())}
    }

    private func listenToAccountTransactions(bankId: String, accountId: String) {
        firestore
            .collection(Constants.Firestore.banksCollection)
            .document(bankId)
            .collection(Constants.Firestore.accountsCollection)
            .document(accountId)
            .rx
            .listen()
            .subscribe(
                onNext: { [weak self] snapshot in
                    guard let self = self else { return }

                },
                onError: { err in
                    print("Unable to listen to \(accountId) transaction updates")
            }).disposed(by: disposeBag)
    }
}
