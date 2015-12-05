import WatchKit
import Foundation
import CoreMotion


class InterfaceController: WKInterfaceController {

    @IBOutlet var xLabel: WKInterfaceLabel!
    @IBOutlet var yLabel: WKInterfaceLabel!
    @IBOutlet var zLabel: WKInterfaceLabel!
    
    let manager = CMMotionManager()
    
    override func willActivate() {
        super.willActivate()
        
        guard manager.accelerometerAvailable else {
            xLabel.setText("⚠️")
            yLabel.setText("⚠️")
            zLabel.setText("⚠️")
            return
        }
        
        manager.accelerometerUpdateInterval = 0.2
        manager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { data, error in
            if let data = data {
                self.xLabel.setText("X: \(data.acceleration.x)")
                self.yLabel.setText("Y: \(data.acceleration.y)")
                self.zLabel.setText("Z: \(data.acceleration.z)")
            } else {
                print(error?.description)
            }
        }
    }

}
