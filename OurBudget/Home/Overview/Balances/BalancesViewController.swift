//
//  BalancesViewController.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/8/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation
import UIKit

import FirebaseFunctions
import FirebaseFirestore
import FirebaseUI
import RxCocoa
import RxSwift

class BalancesViewController : UIViewController {

    @IBOutlet weak var cashBalanceLabel: UILabel!
    @IBOutlet weak var creditBalanceLabel: UILabel!
    @IBOutlet weak var netBalanceLabel: UILabel!
    @IBOutlet weak var savingsBalanceLabel: UILabel!
    @IBOutlet weak var retirementBalanceLabel: UILabel!
    @IBOutlet weak var mortgageBalanceLabel: UILabel!

    private var disposeBag = DisposeBag()
    private lazy var viewModel: BalancesViewModel = BalancesViewModel(functions: Functions.functions(),
                                                                      firestore: Firestore.firestore())

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.cashBalance.asObservable().bind(to: cashBalanceLabel.rx.text).disposed(by: disposeBag)
        viewModel.creditBalance.asObservable().bind(to: creditBalanceLabel.rx.text).disposed(by: disposeBag)
        viewModel.netBalance.asObservable().bind(to: netBalanceLabel.rx.text).disposed(by: disposeBag)
        viewModel.savingsBalance.asObservable().bind(to: savingsBalanceLabel.rx.text).disposed(by: disposeBag)
        viewModel.retirementBalance.asObservable().bind(to: retirementBalanceLabel.rx.text).disposed(by: disposeBag)
        viewModel.mortgageBalance.asObservable().bind(to: mortgageBalanceLabel.rx.text).disposed(by: disposeBag)
    }
}
