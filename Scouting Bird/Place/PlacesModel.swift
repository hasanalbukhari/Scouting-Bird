//
//  PlacesModel.swift
//  Scouting Bird
//
//  Created by Hasan S. Al-Bukhari on 2/20/17.
//  Copyright © 2017 IMENA. All rights reserved.
//

import UIKit
import GoogleMaps

protocol PlacesModelProtocol: class {
    func failWith(error: String)
    func successWith(place: Place!)
    func successWith(places: NSMutableArray)
}

class PlacesModel: NSObject {

    var apiKey: String = "AIzaSyB70WFonQbjtyEQQVYkZWsoE08k-7w1C_A"
    var task: URLSessionDataTask!
    
    weak var delegate: PlacesModelProtocol?
    
    override init() {
        super.init()
    }
    
    convenience init(delegate: PlacesModelProtocol) {
        self.init()
        
        self.delegate = delegate
    }
    
    func getPlaces(coordinate: CLLocationCoordinate2D!) {
        var urlString: String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=500&key=\(apiKey)"
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Log.debug(urlString)
        
        let url = URL(string: urlString)!
        
        if task != nil {
            task.cancel()
        }
        
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async(){
                
                self.task = nil
                
                // parsing could me done on a seperate entity
                if let data = data {
                    if let jsonResult = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? NSDictionary {
                        Log.debug(jsonResult.description)
                        
                        let places: NSMutableArray = NSMutableArray()
                        
                        let returnedPlaces: NSArray? = jsonResult["results"] as? NSArray
                        if returnedPlaces != nil {
                            for index in 0..<returnedPlaces!.count {
                                if let returnedPlace = returnedPlaces?[index] as? NSDictionary {
                                    
                                    let place: Place = Place()
                                    
                                    if let placeId = returnedPlace["place_id"] as? NSString {
                                        place.place_id = placeId as String
                                    }
                                    
                                    if let name = returnedPlace["name"] as? NSString {
                                        place.place_name = name as String
                                    }
                                    
                                    if let vicinity = returnedPlace["vicinity"] as? NSString {
                                        place.place_address = vicinity as String
                                    }
                                    
                                    if let icon = returnedPlace["icon"] as? NSString {
                                        place.place_icon = icon as String
                                    }
                                    
                                    if let geometry = returnedPlace["geometry"] as? NSDictionary {
                                        if let location = geometry["location"] as? NSDictionary {
                                            if let lat = location["lat"] as? Double {
                                                place.place_latitude = lat
                                            }
                                            if let lng = location["lng"] as? Double {
                                                place.place_latitude = lng
                                            }
                                        }
                                    }
                                    
                                    places.add(place)
                                    
                                    Log.debug("index \(index) \(place.place_name) \(place.place_address) \(place.place_latitude) \(place.place_longitue)")
                                }
                            }
                            
                            self.delegate?.successWith(places: places)
                            return
                        }
                    }
                }
                
                if error != nil {
                    Log.debug(error?.localizedDescription)
                    self.delegate?.failWith(error: (error?.localizedDescription)!)
                } else if data == nil {
                    Log.debug("Data is empty")
                    self.delegate?.failWith(error: "Data is empty")
                } else {
                    Log.debug("Something wrong happen")
                    self.delegate?.failWith(error: "Something wrong happen!")
                }
            }
        }
        
        task.resume()
    }
    
    func getPlaceWith(placeId: String) {
        var urlString: String = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&key=\(apiKey)"
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Log.debug(urlString)
        
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async(){
                
                // parsing could me done on a seperate entity
                if let data = data {
                    if let jsonResult = (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? NSDictionary {
                        Log.debug(jsonResult.description)
                        
                        let placeDetails: NSDictionary? = jsonResult["result"] as? NSDictionary
                        if placeDetails != nil {
                            let place: Place = Place()
                            
                            if let website = placeDetails?["website"] as? NSString {
                                place.place_website = website as String
                            }
                            
                            if let phone = placeDetails?["international_phone_number"] as? NSString {
                                place.place_phone = phone as String
                            }
                            
                            Log.debug("Place: \(place.place_website) \(place.place_phone)")
                            self.delegate?.successWith(place: place)
                            return
                        }
                    }
                }
                
                if error != nil {
                    Log.debug(error?.localizedDescription)
                    self.delegate?.failWith(error: (error?.localizedDescription)!)
                } else {
                    Log.debug("Something wrong happen")
                    self.delegate?.failWith(error: "Something wrong happen!")
                }
            }
        }
        
        task.resume()
    }
}
