//
//  Category.swift
//  miniProject
//
//  Created by junsoo on 12/23/24.
//

import Foundation

enum Category: Int {
    case food = 0
    case drink = 1
    case networking = 2
    case company = 3

    var stringValue: String {
        switch self {
        case .food: return "food"
        case .drink: return "drink"
        case .networking: return "networking"
        case .company: return "company"
        }
    }
}
