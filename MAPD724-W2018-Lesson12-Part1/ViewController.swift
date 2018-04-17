import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!

    let defaultLongitude = -79.3832
    let defaultLatitude = 43.6532
    let delta = 5.0
    let mapLocation = CLLocationCoordinate2DMake(43.6532, -79.3832)
    
    @IBOutlet weak var latTF: UITextField!
    @IBOutlet weak var magTF: UITextField!
    @IBOutlet weak var longTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        latTF.text = String(defaultLatitude)
        longTF.text = String(defaultLongitude)
        magTF.text = String(delta)
        self.updateMap(lat: defaultLatitude, long: defaultLongitude, delta: delta)
        self.updateAnn(title: "Toronto", subtitle: "A place that's really cool")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
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
    
    @IBAction func search(_ sender: UIButton) {
        self.updateMap(lat: Double(latTF.text!)!, long: Double(longTF.text!)!, delta: Double(magTF.text!)!)
        self.map.removeAnnotations(self.map.annotations)
        self.updateAnn(title: "Your Location", subtitle: "chosen in a really cool app")
    }

}

