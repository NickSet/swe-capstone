//
//  String+Extension.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/16/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
