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
import Firebase
import FirebaseDatabase


class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextViewDelegate {
    
    var mapView: GMSMapView!
    var window: UIWindow!
    var dropMessageButton: UIButton!
    var dropButton: UIButton!
    var cancelButton: UIButton!
    var messageTextView: UITextView!
    var marker: GMSMarker!
    //var messageDict : [String: Any]
    
    let locationManager = CLLocationManager()
    let TYPEFACE = "AppleSDGothicNeo-SemiBold"
    let MAX_LENGTH = 180 //max length for messages
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //messageDict = [String: Any]()
        
        //Database.database().reference().child("users").child("test").child("messages").observeSingleEvent(of: .value, with: {
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {

            snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                let users = snapshots.compactMap{$0.value as? [String : AnyObject]}
                for user in users
                {
                    print(user)
                    let messages = user["messages"] as? NSArray
                    
                    for message in messages!
                    {
                        let data = message as! [String: AnyObject]
                        let location = CLLocationCoordinate2D(latitude: data["lat"] as! Double, longitude: data["lon"] as! Double)
                        let marker = GMSMarker(position: location)
                        marker.snippet = "\"\(String(describing: data["text"] as! String))\" \n\n Dropped by \(String(describing: user["nickname"] as! String))"
                        marker.map = self.mapView
                    }
                }
            }
            
            
        })
        
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
        
        let camera = GMSCameraPosition.camera(withLatitude: 41, longitude: -87.65, zoom: 3.0)
        mapView.camera = camera
        
        //dropMessageButton formatting
        dropMessageButton = UIButton()
        dropMessageButton.frame.size = CGSize(width: 180, height: 35)
        dropMessageButton.frame.origin = CGPoint(x: 20, y: 30)
        dropMessageButton.center.x = self.view.center.x
        dropMessageButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        dropMessageButton.layer.cornerRadius = 10
        dropMessageButton.layer.borderWidth = 1
        dropMessageButton.layer.borderColor = UIColor.black.cgColor
        dropMessageButton.setTitle("Drop a Message!", for: .normal)
        dropMessageButton.setTitleColor(UIColor.black, for: .normal)
        dropMessageButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        dropMessageButton.titleLabel?.font = UIFont(name: TYPEFACE, size: 20)!
        
        messageTextView = UITextView()
        messageTextView.frame.size = CGSize(width: 235, height: 100)
        messageTextView.frame.origin = CGPoint(x: 20, y: 30)
        messageTextView.center.x = self.view.center.x
        messageTextView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        messageTextView.layer.cornerRadius = 10
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.black.cgColor
        messageTextView.isScrollEnabled = false
        messageTextView.delegate = self
        messageTextView.font = UIFont(name: TYPEFACE, size: 14)
        
        cancelButton = UIButton()
        cancelButton.frame.size = CGSize(width: messageTextView.frame.size.width / 2 - 10, height: 35)
        cancelButton.frame.origin = CGPoint(x: messageTextView.frame.origin.x, y: messageTextView.frame.origin.y + messageTextView.frame.size.height + 10)
        cancelButton.backgroundColor = UIColor.red.withAlphaComponent(0.9)
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        cancelButton.titleLabel?.font = UIFont(name: TYPEFACE, size: 20)!
        
        dropButton = UIButton()
        dropButton.frame.size = CGSize(width: messageTextView.frame.size.width / 2 - 10, height: 35)
        dropButton.frame.origin = CGPoint(x: messageTextView.frame.origin.x + messageTextView.frame.size.width / 2 + 10, y: messageTextView.frame.origin.y + messageTextView.frame.size.height + 10)
        dropButton.backgroundColor = UIColor.green.withAlphaComponent(0.9)
        dropButton.layer.cornerRadius = 10
        dropButton.layer.borderWidth = 1
        dropButton.layer.borderColor = UIColor.black.cgColor
        dropButton.setTitle("Drop!", for: .normal)
        dropButton.setTitleColor(UIColor.black, for: .normal)
        dropButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        dropButton.titleLabel?.font = UIFont(name: TYPEFACE, size: 20)!
        
        dropMessageButton.isHidden = false
        cancelButton.isHidden = true
        dropButton.isHidden = true
        messageTextView.isHidden = true
        
        self.view.addSubview(dropMessageButton)
        self.view.addSubview(cancelButton)
        self.view.addSubview(dropButton)
        self.view.addSubview(messageTextView)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if (sender == dropMessageButton)
        {
            dropMessageButton.isHidden = true
            let location = locationManager.location
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 13.0)
            
            CATransaction.begin()
            CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
            self.mapView?.animate(to: camera)
            CATransaction.commit()
            
            marker = GMSMarker(position: (location?.coordinate)!)
            marker.map = mapView
            marker.tracksInfoWindowChanges = true
            mapView.selectedMarker = marker
            
            
            mapView.isUserInteractionEnabled = false
            
            cancelButton.isHidden = false
            dropButton.isHidden = false
            messageTextView.becomeFirstResponder()
        }
        else if (sender == cancelButton)
        {
            dropMessageButton.isHidden = false
            mapView.isUserInteractionEnabled = true
            
            cancelButton.isHidden = true
            messageTextView.isHidden = true
            dropButton.isHidden = true
            messageTextView.resignFirstResponder()
            
            marker.map = nil
        }
        else if (sender == dropButton)
        {
            dropMessageButton.isHidden = false
            mapView.isUserInteractionEnabled = true
            
            cancelButton.isHidden = true
            messageTextView.isHidden = true
            dropButton.isHidden = true
            messageTextView.resignFirstResponder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        if text.rangeOfCharacter(from: CharacterSet.newlines) == nil && textView.text.count < MAX_LENGTH || text.count == 0 {
            if (text.count == 0)
            {
                marker.snippet = String(textView.text.prefix(textView.text.count - 1))
            }
            else
            {
                marker.snippet = textView.text + text
            }
            return true
        }
        else {
            return false
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
