//
//  BusinessType.swift
//  ServU
//
//  Created by Amber Still on 8/5/25.
//


//
//  BusinessType.swift
//  ServU
//
//  Created by Quian Bowden on 8/4/25.
//

import Foundation
import SwiftUI

// MARK: - Business Type
enum BusinessType: String, CaseIterable, Identifiable, Codable {
    case services = "SERVICES"
    case products = "PRODUCTS"
    case both = "BOTH"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .services: return "Services"
        case .products: return "Products"
        case .both: return "Services & Products"
        }
    }
    
    var icon: String {
        switch self {
        case .services: return "hands.sparkles.fill"
        case .products: return "bag.fill"
        case .both: return "square.grid.2x2.fill"
        }
    }
}