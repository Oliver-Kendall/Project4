//
//  File.swift
//  Project 4
//
//  Created by Oliver Kendall on 25/04/2022.
//

import Foundation

func takeMoney(toSub: Int) -> String {
    if (userDefaults.integer(forKey: "totalSteps") - toSub) >= 0 {
        userDefaults.set(userDefaults.integer(forKey: "totalSteps") - toSub, forKey: "totalSteps")
    }
    return String(userDefaults.integer(forKey: "totalSteps"))
}

//example:
//money = takeMoney(2000)
//would take 2000 away


func clearMoney() -> String {
    userDefaults.set(0, forKey: "totalSteps")
    return "0"
}

//clears all money - only run after an alert, as this will wipe all saved data too
