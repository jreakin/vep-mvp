import Foundation
import CoreLocation

/// Geographic coordinate model
struct Coordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    /// Convert to CLLocationCoordinate2D for MapKit
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Create from CLLocationCoordinate2D
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
