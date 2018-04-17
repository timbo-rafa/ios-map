import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!

    let defaultLongitude = -79.3832
    let defaultLatitude = 43.6532
    let delta = 5.0
    let mapLocation = CLLocationCoordinate2DMake(43.6532, -79.3832)
    
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

}

