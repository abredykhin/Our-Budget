//
//  OverviewViewModel.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 6/23/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import Foundation
import Firebase
import RxFirebaseFirestore
import RxFirebaseAuthentication
import RxFirebaseFunctions
import RxSwift
import RxCocoa

enum OverviewCollectionItem: Equatable {
    case balances
    case budget
    case transactions
}

struct OverviewState {
    let numSections = 3

    func section(at indexPath: IndexPath) -> OverviewCollectionItem? {
        switch indexPath.section {
        case 0:
            return .balances
        case 1:
            return .budget
        case 2:
            return .transactions
        default:
            return nil
        }
    }
}

class OverviewViewModel {
    let state = OverviewState()
}
