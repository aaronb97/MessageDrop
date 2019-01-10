//
//  MapViewController.swift
//  MessageDrop
//
//  Created by Aaron Becker on 1/9/19.
//  Copyright © 2019 Aaron Becker. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var mapView: GMSMapView!
    var window: UIWindow!
    var dropMessageButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
        
        let mapFrameRectangle = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: UIScreen.main.bounds.size
        )
        
        self.mapView = GMSMapView(frame: mapFrameRectangle)
        self.mapView.delegate = self
        
        self.view.addSubview(self.mapView!)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
            locationManager.startUpdatingLocation()
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: 37, longitude: 95.7, zoom: 3.0)
        mapView.camera = camera
        
        dropMessageButton = UIButton()
        dropMessageButton.frame.size = CGSize(width: 180, height: 35)
        dropMessageButton.center.x = self.view.center.x
        dropMessageButton.center.y = 50
        
        dropMessageButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        dropMessageButton.layer.cornerRadius = 10
        dropMessageButton.layer.borderWidth = 1
        dropMessageButton.layer.borderColor = UIColor.black.cgColor
        dropMessageButton.setTitle("Drop a Message!", for: .normal)
        dropMessageButton.setTitleColor(UIColor.black, for: .normal)
        dropMessageButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(dropMessageButton)
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if (sender == dropMessageButton)
        {
            dropMessageButton.isHidden = true
            let location = locationManager.location
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 13.0)
            self.mapView?.animate(to: camera)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
