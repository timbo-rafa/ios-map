import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var latTF: UITextField!
    @IBOutlet weak var magTF: UITextField!
    @IBOutlet weak var longTF: UITextField!
    
    let defaultLongitude = -79.3832
    let defaultLatitude = 43.6532
    let delta = 0.01
    //let mapLocation = CLLocationCoordinate2DMake(43.6532, -79.3832)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        latTF.text = String(defaultLatitude)
        longTF.text = String(defaultLongitude)
        magTF.text = String(delta)
        self.updateMap(lat: defaultLatitude, long: defaultLongitude, delta: delta)
        self.updateAnn(title: "Toronto", subtitle: "A place that's really cool")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        _testAlwaysRequest()
    }
    
    func updateMap( lat: Double, long: Double, delta: Double) {
        let loc = CLLocationCoordinate2DMake(lat, long)
        let span = MKCoordinateSpanMake(delta , delta)
        let reg = MKCoordinateRegionMake(loc, span)
        
        self.map.region = reg
    }
    
    func updateAnn(title: String, subtitle: String) {
        let ann = MKPointAnnotation()
        ann.coordinate = self.map.region.center
        ann.title = title
        ann.subtitle = subtitle
        self.map.addAnnotation(ann)
    }
    
    @IBAction func seeInMapApp(_ sender: UIButton) {
        let placemark = MKPlacemark(coordinate: self.map.region.center, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "Your Location"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue,
            MKLaunchOptionsMapCenterKey: self.map.region.center,
            MKLaunchOptionsMapSpanKey: self.map.region.span
            ])
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func updateFromGPS(coord : CLLocationCoordinate2D) {
        updateTextFields(lat: "\(coord.latitude)", long: "\(coord.longitude)", mag: "\(delta)")
        _search()
    }
    
    func updateTextFields(lat: String, long: String, mag: String) {
        latTF.text = lat
        longTF.text = long
        magTF.text = mag
    }
    
    @IBAction func search(_ sender: UIButton) {
        _search()
    }
    
    func _search() {
        self.updateMap(lat: Double(latTF.text!)!, long: Double(longTF.text!)!, delta: Double(magTF.text!)!)
        self.map.removeAnnotations(self.map.annotations)
        self.updateAnn(title: "Your Location", subtitle: "chosen in a really cool app")
    }

    
    
    
    // EXTERNAL SOURCE CODE
    
    var output = "" {
        willSet {
            // print(newValue)
        }
        didSet {
            self.tv.text = output
            self.tv.scrollRangeToVisible(NSMakeRange((self.tv.text as NSString).length-1,0))
        }
    }
    
    @IBOutlet weak var tv: UITextView!
    let managerHolder = ManagerHolder()
    var locman : CLLocationManager {
        return self.managerHolder.locman
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.locman.delegate = self
    }
    
    var startTime : Date!
    var trying = false
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("did change auth: \(status.rawValue)", to:&output)
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.managerHolder.doThisWhenAuthorized?()
            self.managerHolder.doThisWhenAuthorized = nil
        default: break
        }
    }
    
    var which = 0
    
    @IBAction func testWhenInUseRequest2(_ sender: UIButton) {
        self.managerHolder.checkForLocationAccess()
    }
    
    @IBAction func testAlwaysRequest2(_ sender: UIButton) {
        _testAlwaysRequest()
    }
    
    func _testAlwaysRequest() {
        self.managerHolder.checkForLocationAccess(always:true)
    }
    
    @IBAction func doClear2(_ sender: UIButton) {
        self.tv.text = ""
        self.output = ""
    }
    
    @IBAction func doFindMe2(_ sender: UIButton) {
        self.managerHolder.checkForLocationAccess() {
            self.which = 1
            self.reallyFindMe()
        }
    }
    
    @IBAction func whereAmI2(_ sender: UIButton) {
        self.managerHolder.checkForLocationAccess() {
            self.which = 2
            self.reallyFindMe()
        }
        
    }
    
    func reallyFindMe() {
        switch self.which {
        case 1:
            if self.trying { return }
            self.trying = true
            self.locman.desiredAccuracy = kCLLocationAccuracyBest
            self.locman.distanceFilter = kCLDistanceFilterNone
            self.locman.activityType = .other
            self.locman.pausesLocationUpdatesAutomatically = false
            self.startTime = nil
            print("starting", to:&self.output)
            self.locman.startUpdatingLocation()
        case 2:
            print("requesting", to:&self.output)
            self.locman.desiredAccuracy = kCLLocationAccuracyBest
            self.locman.requestLocation()
        default: break
        }
    }
    
    func stopTrying () {
        self.locman.stopUpdatingLocation()
        self.startTime = nil
        self.trying = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed: \(error)", to:&output)
        self.stopTrying()
    }
    
    @IBAction func stop2(_ sender: UIButton) {
        self.stopTrying()
    }
    
    let REQ_ACC : CLLocationAccuracy = 10
    let REQ_TIME : TimeInterval = 30
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        switch which {
        case 1:
            print("did update location ", to:&output)
            let loc = locations.last!
            let acc = loc.horizontalAccuracy
            let time = loc.timestamp
            let coord = loc.coordinate
            if self.startTime == nil {
                self.startTime = Date()
                return // ignore first attempt
            }
            print("accuracy:", acc, to:&output)
            let elapsed = time.timeIntervalSince(self.startTime)
            if elapsed > REQ_TIME {
                print("This is taking too long", to:&output)
                updateFromGPS(coord: coord)
                print("You might be at \(coord.latitude) \(coord.longitude)", to:&output)
                self.stopTrying()
                return
            }
            if acc < 0 || acc > REQ_ACC {
                return // wait for the next one
            }
            // got it
            updateFromGPS(coord: coord)
            print("You are at \(coord.latitude) \(coord.longitude)", to:&output)
            self.stopTrying()
        case 2:
            let loc = locations.last!
            let coord = loc.coordinate
            updateFromGPS(coord: coord)
            print("The quick way: You are at \(coord.latitude) \(coord.longitude)", to:&output)
            // bug: can be called twice in quick succession
        // ok, the bug is gone; it seems that we just get the cached value the second time
        default: break
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("paused!", to:&output)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("resumed!", to:&output)
    }

}
