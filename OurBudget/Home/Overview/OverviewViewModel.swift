//
//  OverviewViewModel.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 6/23/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation
import Firebase
import RxFirebaseFirestore
import RxFirebaseAuthentication
import RxFirebaseFunctions
import RxSwift
import RxCocoa

class OverviewViewModel {
    private let disposeBag = DisposeBag()
    private let functions: Functions
    private let firestore: Firestore
    private let loginRelay = PublishRelay<Void>()
    private let plaidLinkRelay = PublishRelay<Void>()
    private let cashBalanceRelay = PublishRelay<String>()
    private let creditBalanceRelay = PublishRelay<String>()
    private let retirementBalanceRelay = PublishRelay<String>()

    lazy var login = loginRelay.asSignal()
    lazy var plaidLink = plaidLinkRelay.asSignal()
    lazy var cashBalance = cashBalanceRelay.asSignal()
    lazy var creditBalance = creditBalanceRelay.asSignal()
    lazy var retirementBalance = retirementBalanceRelay.asSignal()

    init(functions: Functions, firestore: Firestore) {
        self.firestore = firestore
        self.functions = functions

        setupAuth()
    }

    func handlePladLinkSuccess(publicToken: String, metadata: [String:Any]) {
        print("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata)")

        let institution = metadata[Constants.Plaid.institution] as! [String:Any]
        let institutionId = institution[Constants.Plaid.institutionId] as! String

        let params = [Constants.Functions.Params.publicToken: publicToken,
                      Constants.Functions.Params.bankId: institutionId]

        // TODO: use in debug only. Also remove arbitrary loads in Plist.info
//        functions.useFunctionsEmulator(origin: "http://localhost:5001")
        functions.httpsCallable(Constants.Functions.addBank).rx.call(params).subscribe(
            onNext: {[weak self] result in
                guard let self = self else { return }
                self.updateAllBalances()
            },
            onError: { err in
                print("Unable to add bank: \(err)")
            }
        ).disposed(by: disposeBag)
    }

    private func setupAuth() {
        Auth.auth().rx.stateDidChange.subscribe(
            onNext: { [weak self] user in
                guard let self = self else { return }
                if let _ = user {
                    self.checkAccounts()
                } else {
                    self.loginRelay.accept(())
                }
            },
            onError: { [weak self] err in
                guard let self = self else { return }

                print("Auth error: \(err)")
                self.loginRelay.accept(())
            }
        ).disposed(by: disposeBag)
    }

    private func checkAccounts() {
        firestore.collection(Constants.Firestore.banksCollection).rx.getDocuments().subscribe(
            onNext: { [weak self] snapshot in
                guard let self = self else { return }

                if snapshot.isEmpty {
                    self.plaidLinkRelay.accept(())
                } else {
                    self.updateAllBalances()
                }
            }
        ).disposed(by: disposeBag)
    }

    private func updateAllBalances() {
        getBalances(accountType: Constants.Firestore.Account.AccountType.credit, relay: creditBalanceRelay)
        getBalances(accountType: Constants.Firestore.Account.AccountType.depository, relay: cashBalanceRelay)
    }

    private func getBalances(accountType: String, relay: PublishRelay<String>) {
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
            .reduce(0.0, accumulator: { acc, snapshot in
                return acc + Account.init(dictionary: snapshot.data()).balance.current
            })
            .subscribe(
                onNext: { totalBalance in
                    relay.accept((String(format: "%.2f", totalBalance)))
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
