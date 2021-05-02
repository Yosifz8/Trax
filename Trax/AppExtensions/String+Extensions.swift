//
//  String+Extensions.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 27/04/2021.
//

import Foundation

extension String {
    static func random(ofLength length: Int) -> String {
        guard length > 0 else { return "" }
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 1...length {
            randomString.append(base.randomElement()!)
        }
        return randomString
    }
}
