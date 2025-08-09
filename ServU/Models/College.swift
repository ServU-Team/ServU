//
//  College.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  College.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  College/university definitions and branding system
//

import SwiftUI
import Foundation

// MARK: - College Model
struct College: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let shortName: String
    let city: String
    let state: String
    let domain: String // Email domain for verification
    let colorScheme: CollegeColorScheme
    let logoImageName: String?
    let website: String
    let studentPopulation: Int?
    let isActive: Bool
    
    // Computed Properties
    var displayName: String {
        return shortName.isEmpty ? name : shortName
    }
    
    var location: String {
        return "\(city), \(state)"
    }
    
    var primaryColor: Color {
        return colorScheme.primary
    }
    
    var secondaryColor: Color {
        return colorScheme.secondary
    }
    
    // Email validation
    func isValidStudentEmail(_ email: String) -> Bool {
        return email.lowercased().hasSuffix("@\(domain.lowercased())")
    }
}

// MARK: - College Color Scheme
struct CollegeColorScheme: Codable, Hashable {
    let primary: Color
    let secondary: Color
    let accent: Color
    let background: Color
    let text: Color
    
    init(primary: Color, secondary: Color, accent: Color? = nil, background: Color? = nil, text: Color? = nil) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent ?? primary
        self.background = background ?? Color(.systemGray6)
        self.text = text ?? Color.primary
    }
    
    // Custom coding for Color
    enum CodingKeys: String, CodingKey {
        case primary, secondary, accent, background, text
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.primary = try container.decode(Color.self, forKey: .primary)
        self.secondary = try container.decode(Color.self, forKey: .secondary)
        self.accent = try container.decode(Color.self, forKey: .accent)
        self.background = try container.decode(Color.self, forKey: .background)
        self.text = try container.decode(Color.self, forKey: .text)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(primary, forKey: .primary)
        try container.encode(secondary, forKey: .secondary)
        try container.encode(accent, forKey: .accent)
        try container.encode(background, forKey: .background)
        try container.encode(text, forKey: .text)
    }
}

// MARK: - College Data Manager
class CollegeDataManager: ObservableObject {
    @Published var colleges: [College] = []
    @Published var selectedCollege: College?
    
    init() {
        loadColleges()
    }
    
    private func loadColleges() {
        colleges = [
            // Major Universities
            College(
                id: UUID(),
                name: "University of Alabama",
                shortName: "Alabama",
                city: "Tuscaloosa",
                state: "AL",
                domain: "crimson.ua.edu",
                colorScheme: CollegeColorScheme(
                    primary: Color(red: 0.65, green: 0.16, blue: 0.16), // Crimson
                    secondary: Color.white
                ),
                logoImageName: "alabama_logo",
                website: "https://www.ua.edu",
                studentPopulation: 38563,
                isActive: true
            ),
            
            College(
                id: UUID(),
                name: "Auburn University",
                shortName: "Auburn",
                city: "Auburn",
                state: "AL",
                domain: "auburn.edu",
                colorScheme: CollegeColorScheme(
                    primary: Color(red: 0.03, green: 0.16, blue: 0.31), // Navy Blue
                    secondary: Color(red: 0.90, green: 0.45, blue: 0.13) // Burnt Orange
                ),
                logoImageName: "auburn_logo",
                website: "https://www.auburn.edu",
                studentPopulation: 31764,
                isActive: true
            ),
            
            College(
                id: UUID(),
                name: "University of Georgia",
                shortName: "UGA",
                city: "Athens",
                state: "GA",
                domain: "uga.edu",
                colorScheme: CollegeColorScheme(
                    primary: Color(red: 0.73, green: 0.09, blue: 0.09), // Georgia Red
                    secondary: Color.black
                ),
                logoImageName: "uga_logo",
                website: "https://www.uga.edu",
                studentPopulation: 39147,
                isActive: true
            ),
            
            College(
                id: UUID(),
                name: "Georgia Institute of Technology",
                shortName: "Georgia Tech",
                city: "Atlanta",
                state: "GA",
                domain: "gatech.edu",
                colorScheme: CollegeColorScheme(
                    primary: Color(red: 0.69, green: 0.53, blue: 0.20), // Old Gold
                    secondary: Color(red: 0.00, green: 0.16, blue: 0.32) // Tech Gold/Navy
                ),
                logoImageName: "gatech_logo",
                website: "https://www.gatech.edu",
                studentPopulation: 46274,
                isActive: true
            ),
            
            College(
                id: UUID(),
                name: "Florida State University",
                shortName: "FSU",
                city: "Tallahassee",
                state: "FL",
                domain: "fsu.edu",
                colorScheme: CollegeColorScheme(
                    primary: Color(red: 0.48, green: 0.09, blue: 0.18), // Garnet
                    secondary: Color(red: 0.72, green: 0.53, blue: 0.04) // Gold
                ),
                logoImageName: "fsu_logo",
                website: "https://www.fsu.edu",
                studentPopulation: 41005,
                isActive: true
            ),
            
            College(
                id: UUID(),
                name: "University of Florida",
                shortName: "UF",
                city: "Gainesville",
                state: "FL",
                domain: "ufl.edu",
                colorScheme: CollegeColorScheme(
                    primary: Color(red: 0.00, green: 0.20, blue: 0.65), // Orange
                    secondary: Color(red: 0.98, green: 0.42, blue: 0.00) // Blue
                ),
                logoImageName: "uf_logo",
                website: "https://www.ufl.edu",
                studentPopulation: 52367,
                isActive: true
            ),
            
            // Add more colleges as needed...
        ]
    }
    
    // MARK: - Helper Methods
    func getCollege(by domain: String) -> College? {
        return colleges.first { $0.domain.lowercased() == domain.lowercased() }
    }
    
    func getCollege(by id: UUID) -> College? {
        return colleges.first { $0.id == id }
    }
    
    func searchColleges(query: String) -> [College] {
        guard !query.isEmpty else { return colleges }
        
        return colleges.filter { college in
            college.name.localizedCaseInsensitiveContains(query) ||
            college.shortName.localizedCaseInsensitiveContains(query) ||
            college.city.localizedCaseInsensitiveContains(query) ||
            college.state.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getCollegeByEmailDomain(_ email: String) -> College? {
        let emailComponents = email.components(separatedBy: "@")
        guard emailComponents.count == 2 else { return nil }
        
        let domain = emailComponents[1].lowercased()
        return colleges.first { $0.domain.lowercased() == domain }
    }
    
    func getActiveColleges() -> [College] {
        return colleges.filter { $0.isActive }
    }
    
    func getCollegesByState(_ state: String) -> [College] {
        return colleges.filter { $0.state.lowercased() == state.lowercased() }
    }
}

// MARK: - Default Colleges
extension CollegeDataManager {
    static var defaultCollege: College {
        return College(
            id: UUID(),
            name: "Default University",
            shortName: "Default",
            city: "Default City",
            state: "XX",
            domain: "default.edu",
            colorScheme: CollegeColorScheme(
                primary: Color.blue,
                secondary: Color.gray
            ),
            logoImageName: nil,
            website: "https://www.example.edu",
            studentPopulation: nil,
            isActive: true
        )
    }
}

// MARK: - Color Extension for Codable
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decodeIfPresent(Double.self, forKey: .alpha) ?? 1.0
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Convert Color to RGB components
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        try container.encode(Double(red), forKey: .red)
        try container.encode(Double(green), forKey: .green)
        try container.encode(Double(blue), forKey: .blue)
        try container.encode(Double(alpha), forKey: .alpha)
    }
}