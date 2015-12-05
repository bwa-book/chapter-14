import WatchKit
import Foundation
import CoreMotion


class InterfaceController: WKInterfaceController {

    @IBOutlet var label: WKInterfaceLabel!
    
    let pedometer = CMPedometer()
    var maxCadence: Double = 0
    
    private func updateLabel() {
        label.setText((String(maxCadence)))
    }

}
