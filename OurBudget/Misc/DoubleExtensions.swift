//
//  DoubleExtensions.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/11/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation

extension Double {
    func presentBalanceValue() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: self))!
    }
}
