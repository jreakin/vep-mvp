import Foundation
import CoreLocation
import Combine

/// Location service for tracking user location and managing location permissions
@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: Error?
    
    private let locationManager: CLLocationManager
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        
        authorizationStatus = locationManager.authorizationStatus
    }
    
    /// Request location permissions
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Start tracking user location
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    /// Stop tracking user location
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Get current location as Coordinate model
    var currentCoordinate: Coordinate? {
        guard let location = currentLocation else { return nil }
        return Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    /// Calculate distance between two coordinates in meters
    func distance(from: Coordinate, to: Coordinate) -> Double {
        let fromLocation = CLLocation(
            latitude: from.latitude,
            longitude: from.longitude
        )
        let toLocation = CLLocation(
            latitude: to.latitude,
            longitude: to.longitude
        )
        return fromLocation.distance(from: toLocation)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            self.currentLocation = location
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = error
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            // Auto-start tracking if authorized
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                self.startTracking()
            }
        }
    }
}
