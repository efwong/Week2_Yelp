//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Edwin Wong on 10/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessDetailViewController: UIViewController {

    var business: Business?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var phoneNumberButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBusiness()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadBusiness(){
        nameLabel.text = business?.name
       // if let imageURL = business?.imageURL{
            //  thumbImageView.setImageWith(imageURL)
        //}
        categoriesLabel.text = business?.categories
        addressLabel.text = business?.address
        reviewsCountLabel.text = "\((business?.reviewCount)!) reviews"
        if let imageURL = business?.ratingImageURL{
            ratingImageView.setImageWith(imageURL)
        }
        distanceLabel.text = business?.distance
        
        // set geo location
        let latitude = (business?.latitude) ?? 37.7833
        let longitude = (business?.longitude) ?? -122.4167
        let centerLocation = CLLocation(latitude: latitude, longitude: longitude)
        goToLocation(location: centerLocation)
        addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2DMake(latitude, longitude))
        
        // set phone Number
        if let phoneNumber = business?.phoneNumber{
            phoneNumberButton.setTitle("Call: \(phoneNumber)", for: .normal)
            phoneNumberButton.isHidden = false
        }else{
            phoneNumberButton.setTitle("Call: 000-0000", for: .normal)
            phoneNumberButton.isHidden = true
        }
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
        
    }

    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    
    @IBAction func onPhoneTap(_ sender: AnyObject) {
        if let phoneNumber = business?.phoneNumber{
            UIApplication.shared.openURL(URL(string: "tel:\(phoneNumber)")!)
        }
        
    }
    @IBAction func onWebsiteTap(_ sender: AnyObject) {
        if let url = business?.websiteURLString{
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }

}
