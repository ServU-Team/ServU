//
//  LocationManager.swift
//  ServU
//
//  Created by Amber Still on 8/9/25.
//


//
//  LocationManager.swift
//  ServU
//
//  Created by Quian Bowden on 8/6/25.
//  Location services for finding nearby businesses and navigation
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var locationError: String?
    @Published var nearbyBusinesses: [EnhancedBusiness] = []
    @Published var isSearchingNearby = false
    
    // Search properties
    @Published var searchRadius: Double = 10.0 // miles
    @Published var maxResults: Int = 50
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
        checkLocationAuthorization()
    }
    
    // MARK: - Authorization
    
    /// Request location permission from user
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Guide user to settings
            locationError = "Location access denied. Please enable in Settings to find nearby businesses."
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            locationError = "Unknown location authorization status"
        }
    }
    
    private func checkLocationAuthorization() {
        authorizationStatus = locationManager.authorizationStatus
        isLocationEnabled = authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        
        if isLocationEnabled {
            startLocationUpdates()
        }
    }
    
    // MARK: - Location Updates
    
    /// Start receiving location updates
    func startLocationUpdates() {
        guard isLocationEnabled else {
            requestLocationPermission()
            return
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            locationError = "Location services are disabled"
            return
        }
        
        locationManager.startUpdatingLocation()
        print("✅ Started location updates")
    }
    
    /// Stop receiving location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        print("🛑 Stopped location updates")
    }
    
    /// Get current location once
    func getCurrentLocation() {
        guard isLocationEnabled else {
            requestLocationPermission()
            return
        }
        
        locationManager.requestLocation()
    }
    
    // MARK: - Business Search
    
    /// Find nearby businesses based on current location
    func findNearbyBusinesses(_ businesses: [EnhancedBusiness]) {
        guard let currentLocation = location else {
            locationError = "Current location not available"
            return
        }
        
        isSearchingNearby = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let filteredBusinesses = businesses.compactMap { business -> (EnhancedBusiness, Double)? in
                guard let businessCoordinate = business.location.coordinate else { return nil }
                
                let businessLocation = CLLocation(
                    latitude: businessCoordinate.latitude,
                    longitude: businessCoordinate.longitude
                )
                
                let distance = currentLocation.distance(from: businessLocation) / 1609.34 // Convert to miles
                
                // Filter by search radius
                guard distance <= self.searchRadius else { return nil }
                
                return (business, distance)
            }
            .sorted { $0.1 < $1.1 } // Sort by distance
            .prefix(self.maxResults) // Limit results
            .map { $0.0 } // Extract businesses
            
            DispatchQueue.main.async {
                self.nearbyBusinesses = Array(filteredBusinesses)
                self.isSearchingNearby = false
                print("✅ Found \(filteredBusinesses.count) nearby businesses")
            }
        }
    }
    
    /// Calculate distance to a specific business
    func distanceTo(business: EnhancedBusiness) -> Double? {
        guard let currentLocation = location,
              let businessCoordinate = business.location.coordinate else {
            return nil
        }
        
        let businessLocation = CLLocation(
            latitude: businessCoordinate.latitude,
            longitude: businessCoordinate.longitude
        )
        
        return currentLocation.distance(from: businessLocation) / 1609.34 // Convert to miles
    }
    
    /// Format distance for display
    func formattedDistance(to business: EnhancedBusiness) -> String {
        guard let distance = distanceTo(business: business) else {
            return "Distance unknown"
        }
        
        if distance < 1.0 {
            return String(format: "%.1f mi", distance)
        } else {
            return String(format: "%.0f mi", distance)
        }
    }
    
    // MARK: - Navigation
    
    /// Open navigation to business in Maps app
    func navigateToBusiness(_ business: EnhancedBusiness) {
        guard let coordinate = business.location.coordinate else {
            locationError = "Business location not available"
            return
        }
        
        let placemark = MKPlacemark(coordinate: coordinate.clLocation)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = business.name
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
        
        print("✅ Opened navigation to \(business.name)")
    }
    
    /// Get directions to business
    func getDirections(to business: EnhancedBusiness, completion: @escaping (MKRoute?) -> Void) {
        guard let currentLocation = location,
              let businessCoordinate = business.location.coordinate else {
            completion(nil)
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: businessCoordinate.clLocation))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("❌ Error calculating directions: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            completion(response?.routes.first)
        }
    }
    
    // MARK: - Geofencing (Future Feature)
    
    /// Set up geofence for business notifications
    func setupGeofence(for business: EnhancedBusiness, radius: CLLocationDistance = 500) {
        guard let coordinate = business.location.coordinate else { return }
        
        let region = CLCircularRegion(
            center: coordinate.clLocation,
            radius: radius,
            identifier: business.id.uuidString
        )
        
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        locationManager.startMonitoring(for: region)
        print("✅ Set up geofence for \(business.name)")
    }
    
    /// Remove geofence for business
    func removeGeofence(for business: EnhancedBusiness) {
        let regions = locationManager.monitoredRegions
        
        if let region = regions.first(where: { $0.identifier == business.id.uuidString }) {
            locationManager.stopMonitoring(for: region)
            print("✅ Removed geofence for \(business.name)")
        }
    }
    
    // MARK: - Utility Methods
    
    /// Check if location services are available
    var isLocationServicesAvailable: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    /// Open location settings
    func openLocationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    /// Get location permission status description
    var permissionStatusDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Location permission not requested"
        case .restricted:
            return "Location access restricted"
        case .denied:
            return "Location access denied"
        case .authorizedWhenInUse:
            return "Location access granted (when in use)"
        case .authorizedAlways:
            return "Location access granted (always)"
        @unknown default:
            return "Unknown location permission status"
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Filter out old or inaccurate readings
        guard newLocation.horizontalAccuracy < 100 else { return }
        
        // Update location if it's significantly different
        if let lastLocation = location {
            let distance = newLocation.distance(from: lastLocation)
            guard distance > 50 else { return } // Only update if moved more than 50 meters
        }
        
        location = newLocation
        locationError = nil
        
        print("✅ Location updated: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error.localizedDescription
        print("❌ Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        isLocationEnabled = status == .authorizedWhenInUse || status == .authorizedAlways
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            startLocationUpdates()
            print("✅ Location authorization granted")
            
        case .denied, .restricted:
            location = nil
            locationError = "Location access denied"
            print("⚠️ Location authorization denied")
            
        case .notDetermined:
            print("⚠️ Location authorization not determined")
            
        @unknown default:
            locationError = "Unknown authorization status"
            print("⚠️ Unknown location authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Handle geofence entry
        if let businessId = UUID(uuidString: region.identifier) {
            NotificationCenter.default.post(
                name: .enteredBusinessArea,
                object: nil,
                userInfo: ["business_id": businessId]
            )
            print("✅ Entered business area: \(region.identifier)")
        }
    }
}

// MARK: - Extensions

extension Coordinate {
    var clLocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    var coordinate: Coordinate {
        return Coordinate(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let enteredBusinessArea = Notification.Name("enteredBusinessArea")
}