//
//  HealthKitPull.swift
//  Project 4
//
//  Created by Oliver Kendall on 09/03/2022.
//

//import Foundation
 
import HealthKit
import SwiftUI

func getHKStatus() -> Bool {
    if HKHealthStore.isHealthDataAvailable() {
        return true
    }
    else {
        return false
    }
}
func authorizeHealthKit() {
    //to do - make this faster
    let HKRead = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
    let HKWrite = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
    HKHealthStore().requestAuthorization(toShare: HKWrite, read: HKRead)  { (success, error) in
        if !success {
            print("faliure")
        }
        else {
            print("success")
        }
    }
    let calendar = NSCalendar.current
    let now = Date()
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
    let endDate = calendar.date(from:components)
    userDefaults.set(endDate, forKey: "prevDate")
    userDefaults.set(true, forKey: "healthKitPopup")
}
