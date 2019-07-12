//
//  Models.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 6/23/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation

struct Transaction {
    let accountId: String
    let amount: Double
    let category: [String]?
    let date: String
    let name: String
    let pending: Bool

    init(dictionary: [String: Any]) {
        self.accountId = dictionary[Constants.Firestore.Transaction.accountId] as! String
        self.amount = dictionary[Constants.Firestore.Transaction.amount] as! Double
        self.category = dictionary[Constants.Firestore.Transaction.category] as? [String] ?? []
        self.date = dictionary[Constants.Firestore.Transaction.date] as! String
        self.name = dictionary[Constants.Firestore.Transaction.name] as! String
        self.pending = dictionary[Constants.Firestore.Transaction.pending] as! Bool
    }
}

struct RecentTransaction {
    let amount: String
    let name: String
    let budgetHit: Int
}

struct Account {
    let id: String
    let balances: Balance
    let mask: String
    let name: String
    let type: String

    init(dictionary: [String: Any]) {
        self.id = dictionary[Constants.Firestore.Account.id] as! String
        self.balances = Balance(dictionary: dictionary[Constants.Firestore.Account.balance] as! [String:Any])
        self.name = dictionary[Constants.Firestore.Account.name] as! String
        self.mask = dictionary[Constants.Firestore.Account.mask] as! String
        self.type = dictionary[Constants.Firestore.Account.type] as! String
    }
}

struct Balance {
    let current: Double
    let available: Double?
    let limit: Double?

    init(dictionary: [String: Any]) {
        self.current = dictionary[Constants.Firestore.Balance.current] as! Double
        self.available = dictionary[Constants.Firestore.Balance.available] as? Double ?? 0.00
        self.limit = dictionary[Constants.Firestore.Balance.limit] as? Double ?? 0.00
    }
}

struct Bank {
    let id: String
    let name: String
    let logo: String?
    let primaryColor: String?

    init(dictionary: [String: Any]) {
        self.id = dictionary[Constants.Firestore.Bank.bankId] as! String
        self.name = dictionary[Constants.Firestore.Bank.name] as! String
        self.logo = dictionary[Constants.Firestore.Bank.logo] as? String
        self.primaryColor = dictionary[Constants.Firestore.Bank.primaryColor] as? String
    }
}

struct Budget {
    let id: String
    let name: String
    let dailyLimit: Double
    let weeklyLimit: Double
    let monthlyLimit: Double

    init(dictionary: [String: Any]) {
        self.id = dictionary[Constants.Firestore.Budget.budgetId] as! String
        self.name = dictionary[Constants.Firestore.Budget.name] as! String
        self.dailyLimit = dictionary[Constants.Firestore.Budget.dailyLimit] as! Double
        self.weeklyLimit = dictionary[Constants.Firestore.Budget.weeklyLimit] as! Double
        self.monthlyLimit = dictionary[Constants.Firestore.Budget.monthlyLimit] as! Double
    }
}
