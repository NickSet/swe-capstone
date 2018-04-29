//
//  String+Extension.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/16/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation

extension String {
    /// Determine if the given `String` contains the `String` being passed in
    /// - Parameter find: The `String` you want to search for
    /// - Returns: A boolean indicating if the given `String` contained the `String` passed in
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    /// Determine if the given `String` contains the `String` being passed in regardless of case
    /// - Parameter find: The `String` you want to search for
    /// - Returns: A boolean indicating if the given `String` contained the `Strin` passed in, regardless of case
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
