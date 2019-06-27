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
    private let totalBalanceRelay = PublishRelay<String>()

    lazy var login = loginRelay.asSignal()
    lazy var plaidLink = plaidLinkRelay.asSignal()
    lazy var totalBalance = totalBalanceRelay.asSignal()

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
                self.getTotalBalance()
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
                    self.getTotalBalance()
                }
            }
        ).disposed(by: disposeBag)
    }

    private func getTotalBalance() {
        firestore.collection(Constants.Firestore.balancesCollection).rx.getDocuments()
            .flatMap { Observable.from($0.documents)}
            .map { $0.data()[Constants.Firestore.Balance.current] as! Double}
            .toArray()
            .subscribe(
                onNext: { [weak self] balances in
                    guard let self = self else { return }
                    let totalBalance = balances.reduce(into: 0.0) { acc, current in
                        acc += current
                    }
                    self.totalBalanceRelay.accept(String(format: "%.2f", totalBalance))
                },
                onError: { error in
                    print("Error fetching accounts: \(error)")
                }
            ).disposed(by: disposeBag)
    }
}