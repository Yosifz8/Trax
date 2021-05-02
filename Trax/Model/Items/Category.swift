//
//  Category.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 27/04/2021.
//

import Foundation

enum Category: Int, CaseIterable, CustomStringConvertible {
    case General
    case Sparkling
    case Coffee
    case Juice
    case Sports
    case VitaminWater
    case Energy
    case Tea
    case Water
    case FlavoredWater
    case SparklingWater
    
    var description: String {
        switch self {
        case .General: return "General"
        case .Sparkling: return "Sparkling"
        case .Coffee: return "Coffee"
        case .Juice: return "Juice"
        case .Sports: return "Sports"
        case .VitaminWater: return "Vitamin Water"
        case .Energy: return "Energy"
        case .Tea: return "Tea"
        case .Water: return "Water"
        case .FlavoredWater: return "Flavored Water"
        case .SparklingWater: return "Sparkling Water"
        }
    }
}
