//
//  DateExtensions.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 7/11/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation

extension Date {

    func format() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE-MM-dd"
        return formatter.string(from: self)
    }

    var dayAgo: Date {
        return Calendar.current.date(byAdding: .weekday, value: 1, to: self)!
    }
}
