//
//  ContentView.swift
//  BetterReset
//
//  Created by Dave Spina on 11/26/20.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeupTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showMessage = false
    
    // needs to be static because we are basing one property on another
    // two instance properties cannot be used
    static var defaultWakeupTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("What time do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter wakeup time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Number of cups of coffee")
                        .font(.headline)
                    Stepper(value: $coffeeAmount, in: 1...20, step: 1) {
                        let cupsString = coffeeAmount > 1 ? "cups" : "cup"
                        Text("\(coffeeAmount) \(cupsString)")
                    }
                }
            }
            .navigationTitle("BetterRest")
            .navigationBarItems(trailing:
                                    Button(action: calculateBedtime) {
                                        Text("Calculate")
                                    }
            // using action: <method> is legal. Just don't need ()
            )
            .alert(isPresented: $showMessage) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
        }
    }
    
    func calculateBedtime() {
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let sleepTimeString = formatter.string(from: sleepTime)
            alertTitle = "Success"
            alertMessage = "You should go to bed at \(sleepTimeString)."
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was an error in predicting your bedtime."
        }
        showMessage = true
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
