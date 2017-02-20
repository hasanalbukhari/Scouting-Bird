//
//  WebViewController.swift
//  La3eeb
//
//  Created by Hasan S. Al-Bukhari on 1/10/17.
//  Copyright © 2017 La3eeb. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, LoadingProtocol, UIWebViewDelegate, PlacesModelProtocol {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingView: LoadingView!
    
    @IBOutlet weak var callButtonItem: UIBarButtonItem!
    
    var place: Place!
    var placesModel: PlacesModel!
    
    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = place.place_name
        Log.info("WebView controller loaded")
        
        // disable call button til the phone number is fetched and verified.
        callButtonItem.isEnabled = false
        
        // setup loading view
        loadingView.delegate = self
        loadingView.setColor(color: .black)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // get place details to use website and phone.
        getPlaceDetails()
    }
    
    // MARK: Actions
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callTapped(_ sender: UIBarButtonItem) {
        let url = URL(string: "tel://\(place.place_phone.replacingOccurrences(of: " ", with: ""))")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    // MARK: Places Model Delegate Methods
    func failWith(error: String) {
        loadingView.stopLoadingWithErrorNoLocalization(msg: error)
    }
    
    func successWith(places: NSMutableArray) {}
    
    func successWith(place: Place!) {
        self.place.place_website = place.place_website
        self.place.place_phone = place.place_phone
        
        if self.place.place_phone != "" {
            callButtonItem.isEnabled = true
        }
        
        loadingView.stopLoading()
        loadUrl()
    }
    
    // MARK: Other Methods
    func getPlaceDetails() {
        webView.isHidden = true
        loadingView.startLoadingWitMessage(msg: "")
        
        if placesModel == nil {
            placesModel = PlacesModel(delegate: self)
        }
        
        // get google place details
        placesModel.getPlaceWith(placeId: place.place_id)
    }

    // loads the website on the webview.
    func loadUrl() {
        if place.place_website != "" {
            webView.isHidden = false
            webView.loadRequest(URLRequest(url: URL(string: place.place_website)!))
            loadingView.startLoadingWitMessageNoLocalization(msg: "")
        } else {
            loadingView.stopLoadingWithMessageNoLocalization(msg: "No website!")
        }
    }
    
    // MARK: Loading View Delegate Methods
    func reload() {
        getPlaceDetails()
    }
    
    // MARK: WebView Delegate Methods
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        Log.debug("webview error: \(error)")
        loadingView.stopLoading()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingView.stopLoading()
    }
}
