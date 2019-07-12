//
//  Constants.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 6/23/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation

struct Constants {
    struct Events {
        static let plaidReady = "PlaidReady"
    }

    struct Functions {
        static let addBank = "addBank"
        static let createMainBudget = "createMainBudget"

        struct Params {
            static let publicToken = "public_token"
            static let bankId = "institution_id"
            static let monthlyIncome = "monthly_income"
            static let monthlyExpenses = "monthly_required_expenses"
        }
    }
    struct Firestore {
        static let banksCollection = "banks"
        static let accountsCollection = "accounts"
        static let transactionsCollection = "transactions"
        static let balancesCollection = "balances"
        static let budgetsCollection = "budgets"
        static let mainBudget = "main"

        struct Balance {
            static let available = "available"
            static let current = "current"
            static let limit = "limit"
        }

        struct Account {
            static let id = "account_id"
            static let mask = "mask"
            static let name = "name"
            static let type = "type"
            static let balance = "balances"
            static let bankId = "bank_id"

            struct AccountType {
                static let depository = "depository"
                static let credit = "credit"
                static let mortgage = "mortgage"
                static let investment = "investment"
                static let loan = "loan"

                struct Subtype {
                    static let checking = "checking"
                    static let creditCard = "credit card"
                    static let savings = "savings"
                    static let _401k = "401k"
                    static let car = "auto"
                    static let mortgage = "mortgage"
                }
            }
        }

        struct Transaction {
            static let accountId = "account_id"
            static let amount = "amount"
            static let category = "category"
            static let date = "date"
            static let name = "name"
            static let pending = "pending"
        }

        struct Bank {
            static let bankId = "id"
            static let name = "name"
            static let logo = "logo"
            static let primaryColor = "primary_color"
        }

        struct Budget {
            static let budgetId = "id"
            static let name = "name"
            static let dailyLimit = "daily_limit"
            static let weeklyLimit = "weekly_limit"
            static let monthlyLimit = "monthly_limit"
        }
    }

    struct Plaid {
        static let institution = "institution"
        static let institutionId = "institution_id"
    }

    struct FCM {
        static let receivedToken = "FCMToken"
        static let newMesssage = "NewMessage"
        static let token = "token"
        static let messageBody = "messageBody"

        struct Topic {
            static let balance = "balance"
        }
    }
}
