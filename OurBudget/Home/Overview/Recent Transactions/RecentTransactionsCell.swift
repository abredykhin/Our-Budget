//
//  LastTransactionsCellView.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/11/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import UIKit

class RecentTransactionsCell: UICollectionViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var merchantLabel: UILabel!
    @IBOutlet weak var budgetHitLabel: UILabel!

    func configure(_ transaction: RecentTransaction) {
        amountLabel.text = transaction.amount
        merchantLabel.text = transaction.name
        budgetHitLabel.text = String(transaction.budgetHit) + "%"
    }
}
