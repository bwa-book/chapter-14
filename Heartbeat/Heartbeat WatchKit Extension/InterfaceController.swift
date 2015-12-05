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

}

// MARK: HealthKit access
extension InterfaceController: HKWorkoutSessionDelegate {
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
