//
//  EntryViewModel.swift
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

class EntryViewModel {

    private let disposeBag = DisposeBag()
    private let functions: Functions
    private let firestore: Firestore
    private let loginRelay = PublishRelay<Void>()
    private let plaidLinkRelay = PublishRelay<Void>()
    private let proceedRelay = PublishRelay<Void>()

    lazy var proceed = proceedRelay.asSignal()
    lazy var login = loginRelay.asSignal()
    lazy var plaidLink = plaidLinkRelay.asSignal()

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
        functions
            .httpsCallable(Constants.Functions.addBank)
            .rx
            .call(params)
            .flatMap { _ in createMainBudget() }
            .subscribe(
                onNext: {[weak self] result in
                    guard let self = self else { return }
                    self.proceedRelay.accept(())
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
                    self.proceedRelay.accept(())
                }
            }
            ).disposed(by: disposeBag)
    }

    private func createMainBudget() -> Observable<Void> {
        let params = [Constants.Functions.Params.monthlyIncome: "6800",
                      Constants.Functions.Params.monthlyExpenses: "5000"]

        return functions
            .httpsCallable(Constants.Functions.createMainBudget)
            .rx
            .call(params)
            .map { _ in () }
    }
}
