//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    let kTagSegue = "tagSegue"
    let kAnnotationViewReuseID = "kAnnotationViewReuseID"
    
    var selectedImage : UIImage?
    var lat : Double?
    var lon : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        mapView.delegate = self
        
        cameraImageView.isUserInteractionEnabled = true
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(photoIconTapped))
        cameraImageView.addGestureRecognizer(tapGR)
    
    }
    
    func photoIconTapped() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        dismiss(animated: true) { 
            self.performSegue(withIdentifier: self.kTagSegue, sender: self)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kTagSegue {
            let locationVC = segue.destination as! LocationsViewController
            locationVC.delegate = self
            locationVC.selectedImage = selectedImage
        }
    }
}

extension PhotoMapViewController : LocationViewControllerDelegate {
    func locationPickedLocation(controller: LocationsViewController, lat: NSNumber, lon: NSNumber) {

        
        self.lat = lat.doubleValue
        self.lon = lon.doubleValue

        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
        pointAnnotation.title = "Picture"
        mapView.addAnnotation(pointAnnotation)
      //  mapView.selectAnnotation(pointAnnotation, animated: true);
        
        self.navigationController?.popToViewController(self, animated: true)
    }
}

extension PhotoMapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kAnnotationViewReuseID)
        
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: kAnnotationViewReuseID)
            annotationView?.canShowCallout = true
            annotationView?.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
        }
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        imageView.image = selectedImage

        return annotationView
    }
}

