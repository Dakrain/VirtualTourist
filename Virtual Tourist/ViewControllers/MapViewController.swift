//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Khoa Lê on 16/11/2023.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var pinModels = [PinModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchPinModels()
    }
    
    
    func fetchPinModels() {
        let fetchRequest: NSFetchRequest<PinModel> = PinModel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "long", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let result = try DataController.shared.viewContext.fetch(fetchRequest)
            pinModels = result
            loadPins(pinModels: result)
        } catch {
            print("error why fetch")
        }
        
    }
    
    func loadPins(pinModels: [PinModel]){
        var annotations = [MKPointAnnotation]()
        
        for item in pinModels {
            let lat = CLLocationDegrees(item.lat)
            let long = CLLocationDegrees(item.long)
            
            let cordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = cordinate
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    func setupViews() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecognizer.delegate = self
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        self.performSegue(withIdentifier: "PinDetail", sender: annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.tintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            // Now we have the coordinate, we can create the annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            let pin = PinModel(context: DataController.shared.viewContext)
            pin.lat = coordinate.latitude
            pin.long = coordinate.longitude
            try? DataController.shared.viewContext.save()
            
            pinModels.append(pin)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PinDetail" {
            if let destinationVC = segue.destination as? PinDetailViewController {
                // Pass any information to the destination view controller here.
                // If you need to pass the annotation data, you can retrieve it from the sender:
                if let annotation = sender as? MKAnnotation {
                    let pin = pinModels.first { pin in
                        return pin.lat == annotation.coordinate.latitude && pin.long == annotation.coordinate.longitude
                    }
                    destinationVC.annotation = annotation
                    destinationVC.pinModel = pin
                }
            }
        }
    }
}


