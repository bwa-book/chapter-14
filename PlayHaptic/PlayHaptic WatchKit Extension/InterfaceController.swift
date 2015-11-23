import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var hapticPicker: WKInterfacePicker!

    @IBAction func stylePicked(value: Int) {
        let hapticStyle = styles[value].1
        WKInterfaceDevice.currentDevice().playHaptic(hapticStyle)
    }

    let styles:[(String, WKHapticType)] = [
        ("Notification", .Notification),
        ("DirectionUp", .DirectionUp),
        ("DirectionDown", .DirectionDown),
        ("Success", .Success),
        ("Failure", .Failure),
        ("Retry", .Retry),
        ("Start", .Start),
        ("Stop", .Stop),
        ("Click", .Click)
    ]

    override func awakeWithContext(context: AnyObject?) {
        let pickerItems: [WKPickerItem] = styles.map { style -> WKPickerItem in
            let pickerItem = WKPickerItem()
            pickerItem.title = style.0
            return pickerItem
        }
        hapticPicker.setItems(pickerItems)

        super.awakeWithContext(context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
