//
//  LocationModel.swift
//  Scouting Bird
//
//  Created by Hasan S. Al-Bukhari on 2/20/17.
//  Copyright © 2017 IMENA. All rights reserved.
//

import UIKit
import GoogleMaps

protocol LocationModelProtocol: class {
    func locationFailWith(error: String)
    func locationSuccessWith(location: CLLocation)
    func locationAuth(state: CLAuthorizationStatus)
}

class LocationModel: NSObject, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    
    weak var delegate: LocationModelProtocol?
    
    override init() {
        super.init()
    }
    
    convenience init(delegate: LocationModelProtocol) {
        self.init()
        
        self.delegate = delegate
    }
    
    func getLocation() {
        if locationManager == nil {
            initLocationManager()
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        } else {
            delegate?.locationFailWith(error: "Enable location service")
        }
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager error: \(error.localizedDescription)")
        delegate?.locationFailWith(error: error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        case .notDetermined:
            print("User still thinking granting location access!")
            locationManager?.stopUpdatingLocation()
            break
            
        case .denied:
            print("User denied location access request!!")
            delegate?.locationAuth(state: .denied)
            locationManager?.stopUpdatingLocation()
            break
            
        case .authorizedWhenInUse:
            delegate?.locationAuth(state: .authorizedWhenInUse)
            locationManager?.startUpdatingLocation() // Will update location immediately
            break
            
        case .authorizedAlways:
            delegate?.locationAuth(state: .authorizedAlways)
            locationManager?.startUpdatingLocation() // Will update location immediately
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("last location: lat \(locations.last?.coordinate.latitude) - lon \(locations.last?.coordinate.longitude)")
        
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
        
        delegate?.locationSuccessWith(location: locations.last!)
    }
}
