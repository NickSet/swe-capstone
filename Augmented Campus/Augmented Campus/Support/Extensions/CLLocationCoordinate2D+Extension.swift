//
//  CLLocationCoordinate2D+Extension.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/6/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation

//
//  CLLocationCoordinate2D+Extension.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 12/6/17.
//  Copyright © 2017 Nicholas Setliff. All rights reserved.
//
import CoreLocation
import Foundation

extension CLLocationCoordinate2D {
    /// Calculate the bearing from the user's location to the given coordinate
    /// - Parameter coordinate: The coordinate to calculate the bearing to
    /// - Returns: The bearing between the user's location and the given coordinate. Value will be between -π and π
    func calculateBearing(to coordinate: CLLocationCoordinate2D) -> Double {
        let a = sin(coordinate.longitude.toRadians() - longitude.toRadians()) * cos(coordinate.latitude.toRadians())
        let b = cos(latitude.toRadians()) * sin(coordinate.latitude.toRadians()) - sin(latitude.toRadians()) * cos(coordinate.latitude.toRadians()) * cos(coordinate.longitude.toRadians() - longitude.toRadians())
        return atan2(a, b)
    }
    
    /// Calculate the direction from the user's location to the given coordinate
    /// - Parameter coordinate: The coordinate to calculate the direction too
    /// - Returns: The direction between the user's location and the given coordinate. Value will be between -180° and 180°
    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        return self.calculateBearing(to: coordinate).toDegrees()
    }
}

/// Extension to confrom `CLLocationCoordinate2D` to the `Hashable` and `Equatable` protocols
extension CLLocationCoordinate2D: Hashable, Equatable {
    /// Required by the `Hashable` protocol. A unique hashable value computed using the `latitude` and `longitude` properties.
    public var hashValue: Int {
        return "\(latitude)\(longitude)".hashValue
    }
    
    /// Required by the `Equatable` protocol. Allows comparisons of `CLLocationCoordinate2D`
    static public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        guard lhs.latitude == rhs.latitude else {
            return false
        }
        
        guard lhs.longitude == rhs.longitude else {
            return false
        }
        
        return true
    }
    
}
