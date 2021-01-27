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
    @State private var coffeeAmount = 0
    
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
                Section(header: Text("What time do you want to wake up?")) {
                    DatePicker("Please enter wakeup time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section(header: Text("Desired amount of sleep")) {
                    Stepper("\(sleepAmount, specifier: "%g") hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .accessibility(label: Text("\(sleepAmount, specifier: "%g") hours of sleep"))
                }
                
                Section(header: Text("Number of cups of coffee")) {
                    Picker(selection: $coffeeAmount, label: Text("Cups")) {
                        ForEach(1..<101) { item in
                            let cupString = item > 1 ? "cups" : "cup"
                            Text("\(item) \(cupString)")
                        }
                    }
                }
                Text("\(alertMessage)")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .font(.largeTitle)
            }
            .navigationTitle("BetterRest")
            .onAppear() {
                calculateBedtime()
            }
            .onChange(of: self.sleepAmount, perform: { value in
                calculateBedtime()
            })
            .onChange(of: self.wakeUp, perform: { value in
                calculateBedtime()
            })
            
        }
    }
    
    func calculateBedtime() {
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount + 1))
            
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
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
