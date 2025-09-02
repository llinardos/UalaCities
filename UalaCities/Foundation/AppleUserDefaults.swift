//
//  File.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation

protocol AppleUserDefaults {
    func set(_ value: [Any]?, forKey key: String)
    func array(forKey key: String) -> [Any]?
    func removeObject(forKey key: String)
}

class RealAppleUserDefaults: AppleUserDefaults {
    private let inner = UserDefaults.standard
    
    func set(_ value: [Any]?, forKey key: String) {
        inner.setValue(value, forKey: key)
    }
    
    func array(forKey key: String) -> [Any]? {
        inner.array(forKey: key)
    }
    
    open func removeObject(forKey key: String) {
        inner.removeObject(forKey: key)
    }
}

class InRamAppleUserDefaults: AppleUserDefaults {
    private var valueByKey: [String: Any] = [:]
    
    func set(_ value: [Any]?, forKey key: String) {
        valueByKey[key] = value
    }
    
    func array(forKey key: String) -> [Any]? {
        valueByKey[key] as? [Any]
    }
    
    open func removeObject(forKey key: String) {
        valueByKey.removeValue(forKey: key)
    }
}
