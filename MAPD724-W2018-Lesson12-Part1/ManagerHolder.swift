
import UIKit
import CoreLocation

class ManagerHolder {
    let locman = CLLocationManager()
    var doThisWhenAuthorized : (() -> ())?
    func checkForLocationAccess(always:Bool = false, andThen f: (()->())? = nil) {
        // no services? fail but try get alert
        guard CLLocationManager.locationServicesEnabled() else {
            print("no location services")
            self.locman.startUpdatingLocation()
            return
        }
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse:
            if always { // try to step up
                self.doThisWhenAuthorized = f
                self.locman.requestAlwaysAuthorization()
            } else {
                f?()
            }
        case .authorizedAlways:
            f?()
        case .notDetermined:
            self.doThisWhenAuthorized = f
            always ?
                self.locman.requestAlwaysAuthorization() :
                self.locman.requestWhenInUseAuthorization()
        case .restricted:
            // do nothing
            break
        case .denied:
            print("denied")
            // do nothing, or beg the user to authorize us in Settings
            break
        }
    }
}
