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
    func calculateBearing(to coordinate: CLLocationCoordinate2D) -> Double {
        let a = sin(coordinate.longitude.toRadians() - longitude.toRadians()) * cos(coordinate.latitude.toRadians())
        let b = cos(latitude.toRadians()) * sin(coordinate.latitude.toRadians()) - sin(latitude.toRadians()) * cos(coordinate.latitude.toRadians()) * cos(coordinate.longitude.toRadians() - longitude.toRadians())
        return atan2(a, b)
    }
    
    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        return self.calculateBearing(to: coordinate).toDegrees()
    }
}

extension CLLocationCoordinate2D: Hashable, Equatable {
    public var hashValue: Int {
        return "\(latitude)\(longitude)".hashValue
    }
    
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
