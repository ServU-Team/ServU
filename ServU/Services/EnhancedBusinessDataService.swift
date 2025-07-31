//
//  EnhancedBusinessDataService.swift
//  ServU
//
//  Created by Amber Still on 7/31/25.
//


//
//  EnhancedBusinessDataService.swift
//  ServU
//
//  Created by Quian Bowden on 7/29/25.
//  Updated by Assistant on 7/31/25.
//  Fixed compilation errors and type mismatches
//

import Foundation

class EnhancedBusinessDataService: ObservableObject {
    
    @Published var allBusinesses: [EnhancedBusiness] = []
    @Published var popularBusinesses: [EnhancedBusiness] = []
    @Published var featuredBusinesses: [EnhancedBusiness] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample contact info
        let sampleContact = ContactInfo(
            email: "contact@business.com",
            phone: "(334) 555-0123",
            instagram: "@businessname",
            website: "www.business.com"
        )
        
        // Create enhanced businesses with products and services
        var businesses: [EnhancedBusiness] = []
        
        // Add individual businesses
        businesses.append(contentsOf: createFlyestAmbitions())
        businesses.append(contentsOf: createDelinquentApparel())
        businesses.append(createLeekEditz())
        businesses.append(contentsOf: createCampusTechStore())
        businesses.append(contentsOf: createServiceBusinesses())
        
        // Assign businesses to lists
        self.allBusinesses = businesses
        self.popularBusinesses = Array(businesses.shuffled().prefix(7))
        self.featuredBusinesses = Array(businesses.filter { $0.rating >= 4.7 }.prefix(3))
    }
    
    // MARK: - Flyest Ambitions - Premium Streetwear Store
    private func createFlyestAmbitions() -> [EnhancedBusiness] {
        let hoodies = [
            createProduct(
                name: "Flyest Ambitions Hoodie - Gold Edition",
                description: "Premium heavyweight hoodie with embroidered logo. Perfect for campus life and representing your ambitions.",
                category: .clothing,
                basePrice: 65.0,
                variants: [
                    createVariant(name: "Small - Black", price: 65.0, attributes: [("Size", "Small"), ("Color", "Black")], quantity: 15),
                    createVariant(name: "Medium - Black", price: 65.0, attributes: [("Size", "Medium"), ("Color", "Black")], quantity: 20),
                    createVariant(name: "Large - Black", price: 65.0, attributes: [("Size", "Large"), ("Color", "Black")], quantity: 18),
                    createVariant(name: "Small - Gold", price: 70.0, attributes: [("Size", "Small"), ("Color", "Gold")], quantity: 10),
                    createVariant(name: "Medium - Gold", price: 70.0, attributes: [("Size", "Medium"), ("Color", "Gold")], quantity: 12),
                    createVariant(name: "Large - Gold", price: 70.0, attributes: [("Size", "Large"), ("Color", "Gold")], quantity: 8)
                ],
                tags: ["streetwear", "hoodie", "campus", "premium"]
            ),
            
            createProduct(
                name: "Flyest Ambitions T-Shirt",
                description: "Soft cotton blend tee with screen-printed design. Comfortable for everyday wear with a message that inspires.",
                category: .clothing,
                basePrice: 28.0,
                variants: [
                    createVariant(name: "Small - White", price: 28.0, attributes: [("Size", "Small"), ("Color", "White")], quantity: 25),
                    createVariant(name: "Medium - White", price: 28.0, attributes: [("Size", "Medium"), ("Color", "White")], quantity: 30),
                    createVariant(name: "Large - White", price: 28.0, attributes: [("Size", "Large"), ("Color", "White")], quantity: 22),
                    createVariant(name: "Small - Black", price: 28.0, attributes: [("Size", "Small"), ("Color", "Black")], quantity: 20),
                    createVariant(name: "Medium - Black", price: 28.0, attributes: [("Size", "Medium"), ("Color", "Black")], quantity: 25),
                    createVariant(name: "Large - Black", price: 28.0, attributes: [("Size", "Large"), ("Color", "Black")], quantity: 18)
                ],
                tags: ["t-shirt", "casual", "everyday", "cotton"]
            ),
            
            createProduct(
                name: "FA Snapback Hat",
                description: "Embroidered snapback cap with adjustable fit. Complete your look with this premium headwear.",
                category: .accessories,
                basePrice: 35.0,
                variants: [
                    createVariant(name: "One Size - Black/Gold", price: 35.0, attributes: [("Size", "One Size"), ("Color", "Black/Gold")], quantity: 15),
                    createVariant(name: "One Size - All Black", price: 35.0, attributes: [("Size", "One Size"), ("Color", "All Black")], quantity: 12)
                ],
                tags: ["hat", "snapback", "accessories", "adjustable"]
            )
        ]
        
        let business = EnhancedBusiness(
            name: "Flyest Ambitions",
            businessType: .products,
            description: "Premium streetwear and lifestyle brand. Elevating your style with unique pieces and exclusive drops. Representing the flyest ambitions of the next generation.",
            rating: 5.0,
            priceRange: .premium,
            imageURL: nil,
            isActive: true,
            location: "Tuskegee University Campus",
            contactInfo: ContactInfo(
                email: "shop@flyestambitions.com",
                phone: "(334) 555-0101",
                instagram: "@flyestambitions",
                website: "www.flyestambitions.com"
            ),
            ownerId: "flyest101",
            ownerName: "Jordan Williams",
            serviceCategories: [],
            services: [],
            availability: BusinessHours.defaultHours,
            products: hoodies,
            productCategories: [.clothing, .accessories],
            shippingOptions: [.campusPickup, .dormDelivery, .standardShipping],
            returnPolicy: "30-day return policy for unworn items with tags. Exchange available for size/color.",
            isVerified: true,
            totalSales: 150
        )
        
        return [business]
    }
    
    // MARK: - Delinquent Apparel - Custom Streetwear Store
    private func createDelinquentApparel() -> [EnhancedBusiness] {
        let clothing = [
            createProduct(
                name: "Delinquent Custom Hoodie",
                description: "Custom designed heavyweight hoodie with unique graphics. Each piece tells a story of creativity and rebellion against the ordinary.",
                category: .clothing,
                basePrice: 58.0,
                variants: [
                    createVariant(name: "Small - Navy", price: 58.0, attributes: [("Size", "Small"), ("Color", "Navy")], quantity: 18),
                    createVariant(name: "Medium - Navy", price: 58.0, attributes: [("Size", "Medium"), ("Color", "Navy")], quantity: 22),
                    createVariant(name: "Large - Navy", price: 58.0, attributes: [("Size", "Large"), ("Color", "Navy")], quantity: 20),
                    createVariant(name: "XL - Navy", price: 60.0, attributes: [("Size", "XL"), ("Color", "Navy")], quantity: 15)
                ],
                tags: ["custom", "hoodie", "streetwear", "graphics"]
            ),
            
            createProduct(
                name: "Delinquent Logo Tee",
                description: "Signature logo t-shirt made from premium cotton. Minimalist design with maximum impact.",
                category: .clothing,
                basePrice: 25.0,
                variants: [
                    createVariant(name: "Small - Black", price: 25.0, attributes: [("Size", "Small"), ("Color", "Black")], quantity: 30),
                    createVariant(name: "Medium - Black", price: 25.0, attributes: [("Size", "Medium"), ("Color", "Black")], quantity: 35),
                    createVariant(name: "Large - Black", price: 25.0, attributes: [("Size", "Large"), ("Color", "Black")], quantity: 28),
                    createVariant(name: "Small - White", price: 25.0, attributes: [("Size", "Small"), ("Color", "White")], quantity: 25),
                    createVariant(name: "Medium - White", price: 25.0, attributes: [("Size", "Medium"), ("Color", "White")], quantity: 30),
                    createVariant(name: "Large - White", price: 25.0, attributes: [("Size", "Large"), ("Color", "White")], quantity: 22)
                ],
                tags: ["logo", "minimalist", "cotton", "signature"]
            ),
            
            createProduct(
                name: "Delinquent Sweatpants",
                description: "Comfortable jogger-style sweatpants with side stripe detail. Perfect for lounging or hitting the gym.",
                category: .clothing,
                basePrice: 45.0,
                variants: [
                    createVariant(name: "Small - Gray", price: 45.0, attributes: [("Size", "Small"), ("Color", "Gray")], quantity: 20),
                    createVariant(name: "Medium - Gray", price: 45.0, attributes: [("Size", "Medium"), ("Color", "Gray")], quantity: 25),
                    createVariant(name: "Large - Gray", price: 45.0, attributes: [("Size", "Large"), ("Color", "Gray")], quantity: 18),
                    createVariant(name: "Small - Black", price: 45.0, attributes: [("Size", "Small"), ("Color", "Black")], quantity: 15),
                    createVariant(name: "Medium - Black", price: 45.0, attributes: [("Size", "Medium"), ("Color", "Black")], quantity: 20),
                    createVariant(name: "Large - Black", price: 45.0, attributes: [("Size", "Large"), ("Color", "Black")], quantity: 12)
                ],
                tags: ["sweatpants", "joggers", "comfort", "gym"]
            )
        ]
        
        let business = EnhancedBusiness(
            name: "Delinquent Apparel",
            businessType: .products,
            description: "Custom streetwear and apparel designed by students, for students. Unique designs that represent college culture and individual expression.",
            rating: 5.0,
            priceRange: .moderate,
            imageURL: nil,
            isActive: true,
            location: "Tuskegee University Campus",
            contactInfo: ContactInfo(
                email: "shop@delinquentapparel.com",
                phone: "(334) 555-0202",
                instagram: "@delinquentapparel",
                website: "www.delinquentapparel.com"
            ),
            ownerId: "delinquent202",
            ownerName: "Maya Jackson",
            serviceCategories: [],
            services: [],
            availability: BusinessHours.defaultHours,
            products: clothing,
            productCategories: [.clothing],
            shippingOptions: [.campusPickup, .dormDelivery],
            returnPolicy: "14-day return policy for custom items. Size exchanges available within 7 days.",
            isVerified: true,
            totalSales: 95
        )
        
        return [business]
    }
    
    // MARK: - LEEK EDITZ - Photography Services
    private func createLeekEditz() -> EnhancedBusiness {
        return EnhancedBusiness(
            name: "Leek Editz",
            businessType: .services,
            description: "Professional photography and video editing services for events, portraits, and social media content. Capturing your best moments with creativity and style.",
            rating: 5.0,
            priceRange: .moderate,
            imageURL: nil,
            isActive: true,
            location: "Tuskegee University Campus",
            contactInfo: ContactInfo(
                email: "leek@tuskegee.edu",
                phone: "(334) 555-0150",
                instagram: "@leekeditz",
                website: "www.leekeditz.com"
            ),
            ownerId: "leek123",
            ownerName: "Marcus Lee",
            serviceCategories: [.photoVideo],
            services: [
                ServUService(name: "Event Photography", description: "Full event coverage with professional editing", price: 150.0, duration: "3 hours", requiresDeposit: true, depositAmount: 50.0, depositType: .fixed, depositPolicy: "50% deposit required to secure booking. Refundable if cancelled 48+ hours before event."),
                ServUService(name: "Portrait Session", description: "Professional headshots and portraits", price: 75.0, duration: "1 hour", requiresDeposit: true, depositAmount: 25.0, depositType: .fixed, depositPolicy: "25% deposit required. Non-refundable if cancelled within 24 hours."),
                ServUService(name: "Video Editing", description: "Professional video editing and color grading", price: 100.0, duration: "2 days", requiresDeposit: false),
                ServUService(name: "Social Media Package", description: "Photos + videos optimized for social media", price: 200.0, duration: "2 hours", requiresDeposit: true, depositAmount: 30.0, depositType: .percentage, depositPolicy: "30% deposit required for social media packages.")
            ],
            availability: BusinessHours.defaultHours,
            products: [],
            productCategories: [],
            shippingOptions: [],
            isVerified: true,
            totalSales: 45
        )
    }
    
    // MARK: - Campus Tech Store - Electronics & Tech Services
    private func createCampusTechStore() -> [EnhancedBusiness] {
        let products = [
            createProduct(
                name: "Wireless Earbuds - Campus Edition",
                description: "High-quality wireless earbuds perfect for students. Great battery life, noise cancellation, and comfortable fit for long study sessions.",
                category: .electronics,
                basePrice: 79.99,
                variants: [
                    createVariant(name: "Black", price: 79.99, attributes: [("Color", "Black")], quantity: 25),
                    createVariant(name: "White", price: 79.99, attributes: [("Color", "White")], quantity: 20)
                ],
                tags: ["wireless", "earbuds", "study", "bluetooth"]
            ),
            
            createProduct(
                name: "Portable Phone Charger",
                description: "10,000mAh portable battery pack with fast charging. Never run out of battery during those long days on campus.",
                category: .electronics,
                basePrice: 35.00,
                variants: [
                    createVariant(name: "Black", price: 35.00, attributes: [("Color", "Black")], quantity: 40),
                    createVariant(name: "Blue", price: 35.00, attributes: [("Color", "Blue")], quantity: 30)
                ],
                tags: ["charger", "portable", "battery", "fast-charging"]
            )
        ]
        
        let services = [
            ServUService(name: "Phone Screen Repair", description: "Quick and affordable phone screen replacement", price: 45.0, duration: "1 hour", requiresDeposit: false),
            ServUService(name: "Laptop Cleaning", description: "Deep cleaning and optimization for laptops", price: 30.0, duration: "2 hours", requiresDeposit: false),
            ServUService(name: "Tech Setup", description: "Help setting up new devices and software", price: 25.0, duration: "1 hour", requiresDeposit: false)
        ]
        
        let business = EnhancedBusiness(
            name: "Campus Tech Store",
            businessType: .both,
            description: "Your one-stop shop for tech products and repair services. We sell quality electronics and provide fast, affordable tech services for students.",
            rating: 4.6,
            priceRange: .moderate,
            imageURL: nil,
            isActive: true,
            location: "Tuskegee University Student Center",
            contactInfo: ContactInfo(
                email: "help@campustech.com",
                phone: "(334) 555-0303",
                instagram: "@campustechtu"
            ),
            ownerId: "tech303",
            ownerName: "Alex Kim",
            serviceCategories: [.other],
            services: services,
            availability: BusinessHours.defaultHours,
            products: products,
            productCategories: [.electronics],
            shippingOptions: [.campusPickup, .dormDelivery],
            returnPolicy: "30-day warranty on all electronics. Service guarantee included.",
            isVerified: true,
            totalSales: 75
        )
        
        return [business]
    }
    
    // MARK: - Service Businesses
    private func createServiceBusinesses() -> [EnhancedBusiness] {
        let sampleContact = ContactInfo(email: "contact@business.com", phone: "(334) 555-0123")
        
        return [
            // Barber
            EnhancedBusiness(
                name: "Golden Tiger Cuts",
                businessType: .services,
                description: "Professional barbering services specializing in modern cuts, fades, and traditional styles. Walk-ins welcome!",
                rating: 4.8,
                priceRange: .budget,
                imageURL: nil,
                isActive: true,
                location: "Near Tuskegee Campus",
                contactInfo: sampleContact,
                ownerId: "tiger456",
                ownerName: "Jerome Washington",
                serviceCategories: [.barber],
                services: [
                    ServUService(name: "Haircut & Style", description: "Complete haircut with styling", price: 20.0, duration: "45 minutes", requiresDeposit: false),
                    ServUService(name: "Beard Trim", description: "Professional beard shaping and trim", price: 15.0, duration: "30 minutes", requiresDeposit: false),
                    ServUService(name: "Hot Towel Shave", description: "Traditional hot towel shave experience", price: 25.0, duration: "30 minutes", requiresDeposit: false)
                ],
                availability: BusinessHours.defaultHours,
                products: [],
                productCategories: [],
                shippingOptions: [],
                isVerified: true,
                totalSales: 120
            ),
            
            // Hair Stylist
            EnhancedBusiness(
                name: "Glam Squad Tuskegee",
                businessType: .services,
                description: "Professional hair styling for all occasions. Specializing in natural hair care, protective styles, and special event looks.",
                rating: 4.9,
                priceRange: .moderate,
                imageURL: nil,
                isActive: true,
                location: "Tuskegee University Area",
                contactInfo: sampleContact,
                ownerId: "glam789",
                ownerName: "Aaliyah Johnson",
                serviceCategories: [.hairStylist],
                services: [
                    ServUService(name: "Wash & Style", description: "Professional wash, condition, and styling", price: 35.0, duration: "1.5 hours", requiresDeposit: false),
                    ServUService(name: "Protective Styling", description: "Braids, twists, and protective styles", price: 80.0, duration: "3 hours", requiresDeposit: true, depositAmount: 25.0, depositType: .percentage, depositPolicy: "25% deposit required for protective styling appointments."),
                    ServUService(name: "Special Event Hair", description: "Formal styling for events and occasions", price: 60.0, duration: "2 hours", requiresDeposit: true, depositAmount: 20.0, depositType: .fixed, depositPolicy: "$20 deposit required for special event styling.")
                ],
                availability: BusinessHours.defaultHours,
                products: [],
                productCategories: [],
                shippingOptions: [],
                isVerified: true,
                totalSales: 80
            ),
            
            // Tutor
            EnhancedBusiness(
                name: "Study Buddy Tutoring",
                businessType: .services,
                description: "Comprehensive academic support for all subjects. Our peer tutors are honor students who understand the Tuskegee curriculum.",
                rating: 4.9,
                priceRange: .budget,
                imageURL: nil,
                isActive: true,
                location: "Tuskegee University Library",
                contactInfo: sampleContact,
                ownerId: "study321",
                ownerName: "David Chen",
                serviceCategories: [.tutor],
                services: [
                    ServUService(name: "Math Tutoring", description: "Algebra through Calculus support", price: 25.0, duration: "1 hour", requiresDeposit: false),
                    ServUService(name: "Science Tutoring", description: "Biology, Chemistry, Physics help", price: 30.0, duration: "1 hour", requiresDeposit: false),
                    ServUService(name: "Writing Center", description: "Essay writing and grammar assistance", price: 20.0, duration: "1 hour", requiresDeposit: false)
                ],
                availability: BusinessHours.defaultHours,
                products: [],
                productCategories: [],
                shippingOptions: [],
                isVerified: true,
                totalSales: 200
            )
        ]
    }
    
    // MARK: - Helper Methods
    private func createProduct(name: String, description: String, category: ProductCategory, basePrice: Double, variants: [ProductVariant], tags: [String]) -> Product {
        return Product(
            name: name,
            description: description,
            category: category,
            basePrice: basePrice,
            images: [ProductImage(imageURL: "", isPrimary: true, altText: name)],
            variants: variants,
            inventory: ProductInventory(quantity: variants.reduce(0) { $0 + $1.inventory.quantity }),
            specifications: [],
            tags: tags
        )
    }
    
    private func createVariant(name: String, price: Double, attributes: [(String, String)], quantity: Int) -> ProductVariant {
        let variantAttributes = attributes.enumerated().map { index, attr in
            VariantAttribute(name: attr.0, value: attr.1, displayOrder: index)
        }
        
        return ProductVariant(
            name: name,
            price: price,
            sku: "SKU\(Int.random(in: 1000...9999))",
            attributes: variantAttributes,
            inventory: ProductInventory(quantity: quantity)
        )
    }
    
    // MARK: - Public Methods
    func getBusinesses(for businessType: BusinessType) -> [EnhancedBusiness] {
        return allBusinesses.filter { business in
            switch businessType {
            case .services:
                return business.businessType == .services || business.businessType == .both
            case .products:
                return business.businessType == .products || business.businessType == .both
            case .both:
                return business.businessType == .both
            }
        }
    }
    
    func getProductBusinesses() -> [EnhancedBusiness] {
        return allBusinesses.filter { $0.businessType == .products || $0.businessType == .both }
    }
    
    func getServiceBusinesses() -> [EnhancedBusiness] {
        return allBusinesses.filter { $0.businessType == .services || $0.businessType == .both }
    }
    
    func searchBusinesses(query: String) -> [EnhancedBusiness] {
        guard !query.isEmpty else { return allBusinesses }
        
        return allBusinesses.filter { business in
            business.name.localizedCaseInsensitiveContains(query) ||
            business.description.localizedCaseInsensitiveContains(query) ||
            business.displayCategories.localizedCaseInsensitiveContains(query) ||
            business.products.contains { $0.name.localizedCaseInsensitiveContains(query) } ||
            business.services.contains { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func addBusiness(_ business: EnhancedBusiness) {
        allBusinesses.append(business)
        // Refresh popular and featured lists
        popularBusinesses = Array(allBusinesses.shuffled().prefix(7))
        featuredBusinesses = Array(allBusinesses.filter { $0.rating >= 4.7 }.prefix(3))
    }
}