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
        beginWorkout()
    }
    
    private func endReadingHeartRate() {
        readingHeartRate = false
        endWorkout()
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
    
    var unit: HKUnit?
    var queryAnchor: HKQueryAnchor?
    var query: HKAnchoredObjectQuery?

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
    
    private func workoutEnded() {
        if let query = query {
            healthStore.stopQuery(query)
        }
    }
    
    private func workoutStarted() {
        unit = HKUnit(fromString: "count/min")
        
        if queryAnchor == nil {
            queryAnchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
        }
        
        query = HKAnchoredObjectQuery(
            type: quantityType!,
            predicate: nil,
            anchor: queryAnchor,
            limit: Int(HKObjectQueryNoLimit),
            resultsHandler: queryUpdateReceived
        )
        
        if let query = query {
            query.updateHandler = queryUpdateReceived
            healthStore.executeQuery(query)
        }
    }
    
    private func queryUpdateReceived(
        query: HKAnchoredObjectQuery,
        samples: [HKSample]?,
        deletedSamples: [HKDeletedObject]?,
        updatedAnchor: HKQueryAnchor?,
        error: NSError?
    ) {
        if let updatedAnchor = updatedAnchor {
            self.queryAnchor = updatedAnchor
            self.heartRateSamplesReceived(samples)
        }
    }
    
    private func heartRateSamplesReceived(samples: [HKSample]?) {
        guard let quantitySamples = samples as? [HKQuantitySample] else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            guard let sample = quantitySamples.first, unit = self.unit else { return }
            
            self.label.setText("\(sample.quantity.doubleValueForUnit(unit))")
        }
    }
    
    // MARK: HKWorkoutSessionDelegate
    
    func workoutSession(
        workoutSession: HKWorkoutSession,
        didChangeToState toState: HKWorkoutSessionState,
        fromState: HKWorkoutSessionState,
        date: NSDate
    ) {
        if toState == .Running {
            workoutStarted()
        } else {
            workoutEnded()
        }
    }
    
    func workoutSession(
        workoutSession: HKWorkoutSession,
        didFailWithError error: NSError
    ) {
        print(error.description)
        endReadingHeartRate()
        label.setText("Error!")
    }
}
