//
//  PinDetailViewController.swift
//  Virtual Tourist
//
//  Created by Khoa Lê on 16/11/2023.
//

import UIKit
import MapKit
import CoreData

class PinDetailViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    var annotation: MKAnnotation?
    var page: Int = 1
    var pinModel: PinModel!
    var fetchedResultsController: NSFetchedResultsController<PictureModel>!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowView: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPhotoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pictureToDelete = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(pictureToDelete)
        try? DataController.shared.viewContext.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<PictureModel> = PictureModel.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pinModel)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "\(pinModel.lat)-\(pinModel.long)")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects?.count == 0 {
                getPhotos()
            } else {
                activityIndicator.stopAnimating()
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("Unexpected NSFetchedResultsChangeType: \(type)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.picture = photo
        cell.getSizes()
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        setupFlow()
        updateLocationsMarker()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setupFlow() {
        let space: CGFloat = 3.0
        let numberOfItemsPerRow: CGFloat = 3
        let totalSpacing: CGFloat = (numberOfItemsPerRow - 1) * space
        let widthAvailableForItems = view.frame.size.width - totalSpacing
        let dimension = widthAvailableForItems / numberOfItemsPerRow
        
        flowView.minimumInteritemSpacing = space
        flowView.minimumLineSpacing = space
        flowView.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func getPhotos() {
        if let annotation = annotation {
            updateCollectionView(photos: [])
            activityIndicator.startAnimating()
            
            FlickrClient.getPhotos(lat: annotation.coordinate.latitude, lng: annotation.coordinate.longitude, page: page, completion: handleGetPhotosResponse(photos:error:))
        }
    }
    
    func handleGetPhotosResponse(photos: Photos?, error: Error?) {
        activityIndicator.stopAnimating()
        if let photos = photos {
            page+=1
            noPhotoLabel.isHidden = photos.photo.count > 0
            updateCollectionView(photos: photos.photo)
        } else {
            newCollectionButton.isEnabled = false
            noPhotoLabel.isHidden = false
        }
    }
    
    func updateCollectionView(photos: [Photo]) {
        if photos.isEmpty {
            if let pictures = pinModel.picture as? Set<PictureModel> {
                for picture in pictures {
                    DataController.shared.viewContext.delete(picture)
                }
            }
        }
        
        for photo in photos {
            let picture = PictureModel(context: DataController.shared.viewContext)
            picture.id = photo.id
            picture.pin = pinModel
            print("save \(photo.id)")
            try? DataController.shared.viewContext.save()
        }
        newCollectionButton.isEnabled = photos.count == 12
    }
    
    func updateLocationsMarker() {
        if let annotation = annotation {
            mapView.addAnnotation(annotation)
            mapView.centerCoordinate = annotation.coordinate
            mapView.selectAnnotation(annotation, animated: true)
            centerMapOnLocation(location: annotation.coordinate)
        }
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 3000 // Adjust the radius as needed
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    @IBAction func newCollectionTapped(_ sender: Any) {
        getPhotos()
    }
}
