import WatchKit
import Foundation
import CoreMotion


class InterfaceController: WKInterfaceController {

    @IBOutlet var xLabel: WKInterfaceLabel!
    @IBOutlet var yLabel: WKInterfaceLabel!
    @IBOutlet var zLabel: WKInterfaceLabel!
    
    let manager = CMMotionManager()

}
