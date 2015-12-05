import UIKit
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationShouldRequestHealthAuthorization(application: UIApplication) {
        HKHealthStore().handleAuthorizationForExtensionWithCompletion { (success, error) in
            
        }
    }

}

