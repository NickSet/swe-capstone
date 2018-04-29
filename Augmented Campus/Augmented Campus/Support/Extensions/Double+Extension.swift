//
//  Double+Extension.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 12/6/17.
//  Copyright © 2017 Nicholas Setliff. All rights reserved.
//

extension Double {
    /// Converts a degree representation of a `Double` to radians
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    /// Converts a radian representation of a `Double` to degrees
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
