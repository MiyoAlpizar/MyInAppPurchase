//
//  AppHelper.swift
//  MyInAppPurchase
//
//  Created by Miyo Alpízar on 25/10/20.
//

import Foundation

enum UserStrings: String {
    case subscriptionID
    case subscriptionName
    case subscriptionStartDate
    case subscriptionEndDate
    case trasnsactionID
}

class AppHelper {
    private static let _shared = AppHelper()
    
    public static var shared: AppHelper {
        return _shared
    }
    
    public var didShowPop: Bool = false
    public var didAskImageUser: Bool = false
    private let lastDateBackGround = "lastDateBackGround"
    private let token = ""
    
    public func setString(type: UserStrings, value: String?) {
        UserDefaults.standard.setValue(value, forKey: type.rawValue)
    }
    
    public func setInt(type: UserStrings, value: Int) {
        UserDefaults.standard.setValue(value, forKey: type.rawValue)
    }
    
    public func setBool(type: UserStrings, value: Bool) {
        UserDefaults.standard.setValue(value, forKey: type.rawValue)
    }
    
    public func setDouble(type: UserStrings, value: Double) {
        UserDefaults.standard.setValue(value, forKey: type.rawValue)
    }
    
    public func setDate(type: UserStrings, value: Date = Date()) {
        UserDefaults.standard.setValue(value, forKey: type.rawValue)
    }
    
   
    public func getString(type: UserStrings) -> String {
        if let value = UserDefaults.standard.value(forKey: type.rawValue) as? String {
            return value
        }
        return ""
    }
    
    public func getInt(type: UserStrings) -> Int {
        if let value = UserDefaults.standard.value(forKey: type.rawValue) as? NSNumber {
            return value.intValue
        }
        return 0
    }
    
    public func getBool(type: UserStrings) -> Bool {
        if let value = UserDefaults.standard.value(forKey: type.rawValue) as? Bool {
            return value
        }
        return false
    }
    
    public func getDouble(type: UserStrings) -> Double {
        if let value = UserDefaults.standard.value(forKey: type.rawValue) as? NSNumber {
            return value.doubleValue
        }
        return 0.0
    }
    
    public func getDate(type: UserStrings) -> Date? {
        if let value = UserDefaults.standard.value(forKey: type.rawValue) as? Date {
            return value
        }
        return nil
    }
    
    public func getTimeElapsed(type: UserStrings) -> Double {
        if let value = UserDefaults.standard.value(forKey: type.rawValue) as? Date {
            return Date().timeIntervalSince(value)
        }
        return 0.0
    }
    
    
    public func removeData(type: UserStrings) {
        UserDefaults.standard.removeObject(forKey: type.rawValue)
    }
    
    public func getArrayString(type: UserStrings) -> [String] {
        var array: [String] = []
        if let value = UserDefaults.standard.value(forKey: type.rawValue) as? String {
            array = value.components(separatedBy: ",")
        }
        return array
    }
    
   
    
    func setLastDateBackGround() {
        UserDefaults.standard.setValue(Date(), forKey: lastDateBackGround)
    }
    
    func deleteLastDateBackGround() {
        UserDefaults.standard.removeObject(forKey: lastDateBackGround)
    }
    
    func restartApp() -> Bool {
        if let date = UserDefaults.standard.value(forKey: lastDateBackGround) as? Date {
            let elapsedTime = Date().timeIntervalSince(date)
            if elapsedTime > 60 * 2 {
                return true
            }
        }
        return false
    }
    
    
    
}
