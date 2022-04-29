//
//  ContentView.swift
//  Project 4
//
//  Created by Oliver Kendall on 08/03/2022.
//

import SwiftUI
import HealthKit
import Foundation

let userDefaults = UserDefaults.standard
var stepavail = ""
let healthStore = HKHealthStore()
//setting variables and constants

struct ContentView: View {
    
    @State var stepCount = ""
    @State var popover = !(userDefaults.bool(forKey: "healthKitPopup"))
    @State var storeOpen = false
    @State var isPresentingConfirm = false
    @State var stepAlert = false
    @State var money = String(userDefaults.integer(forKey: "totalSteps"))
    //@State variables update related UI elements when they are updated - this is useful for counters and popups.
    
    var body: some View {
            HStack(alignment: .center) {
                //only displays healthkit authorisation if it hasn't popped up before
                Button("\(Image(systemName: "sterlingsign.square"))\nGet paid!") {
                    let calendar = NSCalendar.current
                    let now = Date()
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
                    //set up the calendar, the current date, and gets today's date
                    
                    guard let startDate = userDefaults.object(forKey: "prevDate") as? Date else {
                        fatalError("!!!Could not create start date!!!")
                    }
                    //throws a fatal error if for some reason the start date cannot be created
                    //will always make an error if date not present, fix this!!!
                    
                    guard let endDate = calendar.date(from:components) else {
                        fatalError("!!!Could not create end date!!!")
                    }
                    //throws a fatal error if for some reason the end date cannot be created (this should never happen??)
                    
                    let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
                    //defines today for the query
                    
                    guard let stepsTaken = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
                        fatalError("!!!Unable to get the step count!!!")
                    }
                    //defines stepsTaken ^^^
                    
                    let query = HKStatisticsQuery(quantityType: stepsTaken, quantitySamplePredicate: today, options: .cumulativeSum) { (query, statisticsOrNil, errorOrNil) in
                        
                        guard let statistics = statisticsOrNil else {
                            stepCount = "You've done no work at all!"
                            stepAlert = true
                            return
                        }
                        
                        let sum = statistics.sumQuantity()
                        let steps = Int(sum?.doubleValue(for: HKUnit.count()) ?? -1)
                        
                        //update app here
                        //dispatch to the main queue before modifying the ui
                        
                        DispatchQueue.main.async {
                            //update ui Here
                            //please implement some error handling
                            userDefaults.set(endDate, forKey: "prevDate")
                            userDefaults.set(userDefaults.integer(forKey: "totalSteps") + steps, forKey: "totalSteps")
                            money = String(userDefaults.integer(forKey: "totalSteps"))
                            stepCount = "You've earned " + String(steps) + " Coins!"
                            stepAlert = true
                        }
                    }
                    healthStore.execute(query)
                }
                .frame(maxWidth: .infinity)
                .alert(stepCount, isPresented: $stepAlert) {}
                .contextMenu() {
                    Button("Reopen authorisation popup") {
                        popover = true
                    }
                    Button("Free money") {
                        money = takeMoney(toSub: -30000)
                    }
                    //FOR DEMONSTRATION ONLY!!
                }
                Button("\(Image(systemName: "antenna.radiowaves.left.and.right"))\nPlay game!") {print("not yet implemented")}
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray)
                Button("\(Image(systemName: "bag"))\nOpen store!") { storeOpen = true }
                    .frame(maxWidth: .infinity)
            }
            Text(money + " Coins")
                .multilineTextAlignment(.center)
                .padding(.top)
            
                .popover(isPresented: $storeOpen) {
                    //rewrite as scene to swipe to (to the right of main scene)
                    Text("Shop")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .padding(10.0)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                    
                    List{
                        Button(action: {
                            money = takeMoney(toSub: 1000)
                        }) {
                            Text("Bread")
                                .font(.title)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    alignment: .topLeading
                                )
                            HStack {
                                Image("breadIcon")
                                    .resizable(resizingMode: .stretch)
                                    .frame(width: 100.0, height: 100.0)
                                Text("Very filling, but it's a bit plain. (+60HNG, +5HPY)")
                                    .fontWeight(.light)
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .topLeading
                            )
                            Text("Price: 1000 Coins")
                                .multilineTextAlignment(.leading)
                        }
                        Button(action: {
                            money = takeMoney(toSub: 3000)
                        }) {
                            Text("Cake")
                                .font(.title)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    alignment: .topLeading
                                )
                            HStack {
                                Image("cakeIcon")
                                    .resizable(resizingMode: .stretch)
                                    .frame(width: 100.0, height: 100.0)
                                Text("A delicious cake. Kinda filling and VERY delicious (+20HNG, +50HPY)")
                                    .fontWeight(.light)
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .topLeading
                            )
                            Text("Price: 3000 Coins")
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(0.0)
                    .foregroundColor(.accentColor)
                    Text(money + " Coins")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .padding([.top, .leading])
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                }
                .popover(isPresented: $popover) {
                    Text("A popup will appear asking you to provide authorisation for Apple Health. This is required for app functionality so please give it access!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .frame(width: 300.0)
                    
                    Button("\(Image(systemName: "heart")) Authorise Apple Health") {
                        authorizeHealthKit()
                        popover = false
                    }
                    .padding(.all)
                }
        }
    }

