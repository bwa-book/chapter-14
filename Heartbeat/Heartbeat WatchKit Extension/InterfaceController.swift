import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController {

    @IBOutlet var button: WKInterfaceButton!
    @IBOutlet var label: WKInterfaceLabel!
    
    @IBAction func buttonTapped() {
        if readingHeartRate {
            endReadingHeartRate()
        } else {
            beginReadingHeartRate()
        }
    }
    
    private var readingHeartRate = false {
        didSet {
            updateButton()
        }
    }
    
    private func updateButton() {
        if readingHeartRate {
            button.setTitle("Stop")
        } else {
            button.setTitle("Start")
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        label.setText("-")
        updateButton()
    }
    
    private func beginReadingHeartRate() {
        readingHeartRate = true
    }
    
    private func endReadingHeartRate() {
        readingHeartRate = false
    }
    
    let healthStore = HKHealthStore()
    var quantityType: HKQuantityType?
    var workoutSession: HKWorkoutSession? {
        didSet {
            workoutSession?.delegate = self
        }
    }
    
    private func updateWithNoAccess() {
        label.setText("⚠️")
        endReadingHeartRate()
    }

}

// MARK: HealthKit access
extension InterfaceController: HKWorkoutSessionDelegate {
    
    private func beginWorkout() {
        guard HKHealthStore.isHealthDataAvailable() else {
            updateWithNoAccess()
            print("HealthKit unavailable")
            return
        }
        
        quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        if let quantityType = quantityType {
            healthStore.requestAuthorizationToShareTypes(
                nil,
                readTypes: Set([quantityType]),
                completion: accessRequestReturned
            )
        } else {
            updateWithNoAccess()
            print("No quantity type")
        }
    }
    
    private func accessRequestReturned(allowed: Bool, error: NSError?) {
        guard allowed else {
            updateWithNoAccess()
            print(error?.description)
            return
        }
        
        workoutSession = HKWorkoutSession(activityType: .Other, locationType: .Indoor)
        
        if let workoutSession = workoutSession {
            healthStore.startWorkoutSession(workoutSession)
        }
    }
    
    private func endWorkout() {
        if let workoutSession = workoutSession {
            healthStore.endWorkoutSession(workoutSession)
        }
    }
    
    // MARK: HKWorkoutSessionDelegate
    
    func workoutSession(
        workoutSession: HKWorkoutSession,
        didChangeToState toState: HKWorkoutSessionState,
        fromState: HKWorkoutSessionState,
        date: NSDate
    ) {
        
    }
    
    func workoutSession(
        workoutSession: HKWorkoutSession,
        didFailWithError error: NSError
    ) {
        
    }
}
