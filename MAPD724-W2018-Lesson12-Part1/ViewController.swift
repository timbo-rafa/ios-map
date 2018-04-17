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
        
        let loc = CLLocationCoordinate2DMake(defaultLatitude, defaultLongitude)
        let span = MKCoordinateSpanMake(delta , delta)
        let reg = MKCoordinateRegionMake(loc, span)
        
        self.map.region = reg
        
        let ann = MKPointAnnotation()
        ann.coordinate = self.mapLocation
        ann.title = "Toronto"
        ann.subtitle = "A place's that really cool"
        self.map.addAnnotation(ann)
    }
    
    @IBAction func seeInMapApp(_ sender: UIButton) {
        let placemark = MKPlacemark(coordinate: self.mapLocation, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "A really icy place"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue,
            MKLaunchOptionsMapCenterKey: self.map.region.center,
            MKLaunchOptionsMapSpanKey: self.map.region.span
            ])
    }

}

