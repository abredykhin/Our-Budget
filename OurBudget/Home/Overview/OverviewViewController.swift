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
    @IBOutlet weak var totalBalanceLabel: UILabel!

    private lazy var viewModel: OverviewViewModel =
        OverviewViewModel(functions: Functions.functions(), firestore: Firestore.firestore())

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.totalBalance.asObservable().bind(to: totalBalanceLabel.rx.text).disposed(by: disposeBag)
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


    /*
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!

    private lazy var functions = Functions.functions()
    private lazy var db = Firestore.firestore()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(OverviewViewController.didReceiveNotification(_:)), name: NSNotification.Name(rawValue: "PLDPlaidLinkSetupFinished"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linkButton.isEnabled = false
        let linkKitBundle  = Bundle(for: PLKPlaidLinkViewController.self)
        let linkKitVersion = linkKitBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let linkKitBuild   = linkKitBundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String)!
        let linkKitName    = linkKitBundle.object(forInfoDictionaryKey: kCFBundleNameKey as String)!
        infoLabel.text         = "Swift 5 — \(linkKitName) \(linkKitVersion)+\(linkKitBuild)"    }

    @IBAction func linkTapped(_ sender: Any) {
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet
        }
        present(linkViewController, animated: true)
    }

    @objc func didReceiveNotification(_ notification: NSNotification) {
        if notification.name.rawValue == "PLDPlaidLinkSetupFinished" {
            NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
            linkButton.isEnabled = true
        }
    }

    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        //presentAlertViewWithTitle("Success", message: "token: \(publicToken)\nmetadata: \(metadata ?? [:])")\

        let data = ["publicToken": publicToken]

        // TODO: local debug
        //functions.useFunctionsEmulator(origin: "http://localhost:5001")
        functions.httpsCallable("addBankItem").call(data) { (result, err) in
            if let error = err as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    let r = 1 + 2
                }
            }


        }
    }

    func handleError(_ error: Error, metadata: [String : Any]?) {
        presentAlertViewWithTitle("Failure", message: "error: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
    }

    func handleExitWithMetadata(_ metadata: [String : Any]?) {
        presentAlertViewWithTitle("Exit", message: "metadata: \(metadata ?? [:])")
    }

    func presentAlertViewWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension OverviewViewController : PLKPlaidLinkViewDelegate {

    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            NSLog("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            self.handleSuccessWithToken(publicToken, metadata: metadata)
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
}

 */
