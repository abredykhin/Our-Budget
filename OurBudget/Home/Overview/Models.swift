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
    let amount: Float
    let category: [String]?
    let date: String
    let name: String
    let pending: Bool

    init(dictionary: [String: Any]) {
        self.accountId = dictionary[Constants.Firestore.Transaction.accountId] as! String
        self.amount = Float(dictionary[Constants.Firestore.Transaction.amount] as! String)!
        self.category = dictionary[Constants.Firestore.Transaction.category] as? [String] ?? []
        self.date = dictionary[Constants.Firestore.Transaction.date] as! String
        self.name = dictionary[Constants.Firestore.Transaction.name] as! String
        self.pending = dictionary[Constants.Firestore.Transaction.pending] as! Bool
    }
}

struct Account {
    let id: String
    let balance: Balance
    let mask: String
    let name: String
    let type: String

    init(dictionary: [String: Any]) {
        self.id = dictionary[Constants.Firestore.Account.id] as! String
        self.balance = Balance(dictionary: dictionary[Constants.Firestore.Account.balance] as! [String:Any])
        self.name = dictionary[Constants.Firestore.Account.name] as! String
        self.mask = dictionary[Constants.Firestore.Account.mask] as! String
        self.type = dictionary[Constants.Firestore.Account.type] as! String
    }
}

struct Balance {
    let current: Float
    let available: Float?
    let limit: Float?

    init(dictionary: [String: Any]) {
        self.current = Float(dictionary[Constants.Firestore.Balance.current] as! String)!
        self.available = Float(dictionary[Constants.Firestore.Balance.available] as? String ?? "0.0")
        self.limit = Float(dictionary[Constants.Firestore.Balance.limit] as? String ?? "0.0")
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
