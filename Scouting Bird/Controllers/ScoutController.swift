//
//  ScoutController.swift
//  Scouting Bird
//
//  Created by Hasan S. Al-Bukhari on 2/19/17.
//  Copyright © 2017 IMENA. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps
import AlamofireImage

class ScoutController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlacesModelProtocol, LocationModelProtocol {

    @IBOutlet weak var birdImageView: UIImageView!
    @IBOutlet weak var placestTableView: UITableView!

    // will be used to show messages to the user.
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteView: UIView!

    @IBOutlet weak var verBirdConstraint: NSLayoutConstraint!
    
    var lastLocation: CLLocation?
    var places: NSMutableArray!
    
    var showClickBirdNote: Bool = true
    var firstTimeAppears: Bool = true
    
    var placesModel: PlacesModel!
    var locationModel: LocationModel!
    
    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.info("Scout controller loaded")
        
        places = NSMutableArray()
        
        noteView.isHidden = true
        // style note view.
        noteView.layer.cornerRadius = 10.0
        
        birdImageView.isHidden = true
        // flip bird
        birdImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        // style tableview
        placestTableView.tableFooterView = UIView(frame: .zero)
        placestTableView.separatorStyle = .none
        
        // set bird animation sprite
        Common.setupBirdImageAnimationFor(imageView: birdImageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // if first time, animate bird before getting places.
        if firstTimeAppears {
            firstTimeAppears = false
            animateBirdUp()
        }
    }
    
    // MARK: Animation Methods
    func animateBirdUp() {
        // set starting stat.
        birdImageView.isHidden = false
        verBirdConstraint.constant = -birdImageView.frame.size.height/2.0 + view.frame.size.height * 0.2
        
        // layout views
        view.layoutIfNeeded()

        // set animation contants
        verBirdConstraint.constant = 0
        
        // animate
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) -> Void in
            // animation finished. ask user for location and then get places.
            self.getLocation()
        })
    }
    
    // MARK: Actions
    @IBAction func birdTapped(_ sender: UITapGestureRecognizer) {
        // refresh places list.
        noteView.isHidden = true
        showClickBirdNote = false
        getLocation()
    }
    
    // MARK: TableView DataSource & Delegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PlaceCell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell") as! PlaceCell
        
        cell.selectionStyle = .none

        let place: Place = places.object(at: indexPath.row) as! Place
        
        cell.placeNameLabel.text = place.place_name
        cell.placeAddressLabel.text = place.place_address
        
        cell.placeImageView.image = nil
        Alamofire.request(place.place_icon).responseImage { response in
            if let image = response.result.value {
                cell.placeImageView.image = image
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "WebViewSegue", sender: places.object(at: indexPath.row))
    }
    
    // MARK: Location Model Delegate Methods
    func locationSuccessWith(location: CLLocation) {
        lastLocation = location
        getPlaces()
    }
    
    func locationFailWith(error: String) {
        showNote(message: error)
    }
    
    func locationAuth(state: CLAuthorizationStatus) {
        if state == .denied {
            showNote(message: "Enable location service")
        } else {
            noteView.isHidden = true
        }
    }
    
    func showNote(message: String) {
        noteView.isHidden = false
        noteLabel.text = message
    }
    
    // ask for location service permision and get current location.
    func getLocation() {
        if locationModel == nil {
            locationModel = LocationModel(delegate: self)
        }
        
        locationModel.getLocation()
    }
    
    // prepare view for loading
    func prepareFor(loading: Bool) {
        birdImageView.animationDuration = loading ? 0.3 : 1.5
        birdImageView.startAnimating()
    }
    
    // MARK: Places Model Delegate Methods
    func failWith(error: String) {
        prepareFor(loading: false)
        
        showNote(message: error)
    }
    
    func successWith(place: Place!) {}
    
    func successWith(places: NSMutableArray) {
        prepareFor(loading: false)
        
        if showClickBirdNote {
            // this is the first time places is shown. show the hint.
            showNote(message: "I am clickable")
        }
        
        self.places = places
        placestTableView.reloadData()
    }
    
    // get google nearby places.
    func getPlaces() {
        prepareFor(loading: true)
        
        if placesModel == nil {
            placesModel = PlacesModel(delegate: self)
        }
        
        placesModel.getPlaces(coordinate: lastLocation?.coordinate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "WebViewSegue" {
            let controller: WebViewController = (segue.destination as! UINavigationController).topViewController as! WebViewController
            controller.place = sender as! Place
        }
    }
}
