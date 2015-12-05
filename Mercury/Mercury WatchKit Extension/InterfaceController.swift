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
    
    override func willActivate() {
        super.willActivate()
        
        guard CMPedometer.isCadenceAvailable() else {
            label.setText("⚠️")
            return
        }
        
        updateLabel()
        
        pedometer.startPedometerUpdatesFromDate(NSDate()) { data, error in
            guard let data = data else {
                print(error?.description)
                self.label.setText("⚠️")
                return
            }
            
            if let cadence = data.currentCadence?.doubleValue {
                self.maxCadence = cadence
                self.updateLabel()
            }
        }
    }

}
