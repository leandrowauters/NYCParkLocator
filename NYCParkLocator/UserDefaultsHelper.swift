//
//  UserDefultsHelper.swift
//  NYCParkLocator
//
//  Created by Leandro Wauters on 8/25/21.
//

import Foundation

class UserDefaultsHelper {
    
    static let defaults = UserDefaults.standard
    static let saveFilterCategories = "FilterCategories"
    
    static func saveFilterCategories(categories: [String]) {
        defaults.set(categories, forKey: saveFilterCategories)
    }
    
    static func loadFilterCategories() -> [String] {
        return defaults.object(forKey:saveFilterCategories) as? [String] ?? [String]()
    }
}
