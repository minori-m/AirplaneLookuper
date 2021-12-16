//
// Utility.swift
// AWSS3Integration
//
// Created by Soham Paul
// Copyright © 2019 Personal. All rights reserved.
//
import Foundation
extension String {
    func between(_ left: String, _ right: String) -> String? {
        guard let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
                ,leftRange.upperBound <= rightRange.lowerBound else { return nil }
        let sub = self[leftRange.upperBound...]
        let closestToLeftRange = sub.range(of: right)!
        return String(sub[..<closestToLeftRange.lowerBound])
    }
    func fromStringToEnd(_ left: String) -> String? {
        guard let leftRange = range(of: left) else { return nil }
        let sub = self[leftRange.upperBound...]
        return String(sub)
        //
        // https://s3-ap-south-1.amazonaws.com/sohampaul/B1A7A029-0731-4F40-858C-B44828019E62-5252-00000C4DD1360657.txt
        //String -> “sohampaul/”
        // B1A7A029–0731–4F40–858C-B44828019E62–5252–00000C4DD1360657.txt
        //
    }
}
extension StringProtocol {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
}
extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        guard let strongSelf = self else {
            return nil
        }
        return strongSelf.isEmpty ? nil : strongSelf
    }
}
