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
import FirebaseUI
import LinkKit
import RxCocoa
import RxSwift

class OverviewViewController: UIViewController {

    private let disposeBag = DisposeBag()
    @IBOutlet weak var cashBalanceLabel: UILabel!
    @IBOutlet weak var crerditBalanceLabel: UILabel!
    @IBOutlet weak var retirementBalanceLabel: UILabel!
    
    private lazy var viewModel: OverviewViewModel =
        OverviewViewModel(functions: Functions.functions(), firestore: Firestore.firestore())

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.cashBalance.asObservable().bind(to: cashBalanceLabel.rx.text).disposed(by: disposeBag)
        viewModel.creditBalance.asObservable().bind(to: crerditBalanceLabel.rx.text).disposed(by: disposeBag)
        viewModel.retirementBalance.asObservable().bind(to: retirementBalanceLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.login.emit(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.login()
        }).disposed(by: disposeBag)
        viewModel.plaidLink.emit(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.plaidLink()
        }).disposed(by: disposeBag)
    }

    @IBAction func linkAccountTapped(_ sender: UIButton) {
        plaidLink()
    }

    private func login() {
        let authUI = FUIAuth.defaultAuthUI()!
        authUI.providers = [FUIGoogleAuth()]
        authUI.delegate = self
        let authViewController = authUI.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }

    private func plaidLink() {
        let linkViewController = PLKPlaidLinkViewController(delegate: self)
        present(linkViewController, animated: true)
    }

}

extension OverviewViewController : FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let error = error {
            print("Unable to sign-in \(error)")
            login()
        }
    }
}

extension OverviewViewController : PLKPlaidLinkViewDelegate {

    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            self.viewModel.handlePladLinkSuccess(publicToken: publicToken, metadata: metadata!)
        }
    }

    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
                self.handleError(error, metadata: metadata)
            }
            else {
                NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
                self.handleExitWithMetadata(metadata)
            }
        }
    }

    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didHandleEvent event: String, metadata: [String : Any]?) {
        NSLog("Link event: \(event)\nmetadata: \(metadata ?? [:])")
    }

    private func handleError(_ error: Error, metadata: [String : Any]?) {
        presentAlertViewWithTitle("Failure", message: "error: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
    }

    private func handleExitWithMetadata(_ metadata: [String : Any]?) {
        presentAlertViewWithTitle("Exit", message: "metadata: \(metadata ?? [:])")
    }

    private func presentAlertViewWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
