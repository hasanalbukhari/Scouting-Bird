//
//  LoadingView.swift
//  Maharah
//
//  Created by Hasan Al-Bukhari on 12/14/16.
//  Copyright © 2016 Maharah. All rights reserved.
//

import UIKit

protocol LoadingProtocol: class {
    func reload()
}

class LoadingView: UIView {
    
    internal weak var delegate : LoadingProtocol?
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var successImageView: UIImageView!
    
    var message: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        activityIndicator.stopAnimating()
        messageLabel.isHidden = true
        isHidden = true
    }
    
    func setColor(color: UIColor) {
        activityIndicator.color = color
        messageLabel.textColor = color
        reloadButton.tintColor = color
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if view.superview != self {
            return
        }
        
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))
        
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0))
        
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0))
        
        addConstraint(NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
    }
    
    func stopLoadingWithSuccess() {
        stopLoading()
        successImageView.isHidden = false
        isHidden = false
    }
    
    func startLoadingWitMessage(msg: String) {
        activityIndicator.startAnimating()
        setMessageText(msg)
        isHidden = false
        reloadButton.isHidden = true
        successImageView.isHidden = true
    }
    
    func startLoadingWitMessageNoLocalization(msg: String) {
        activityIndicator.startAnimating()
        setMessageTextNoLocalization(msg)
        isHidden = false
        reloadButton.isHidden = true
        successImageView.isHidden = true
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        setMessageText(nil)
        reloadButton.isHidden = true

        successImageView.isHidden = true
        isHidden = true
    }
    
    func stopLoadingWithMessage(msg: String) {
        activityIndicator.stopAnimating()
        setMessageText(msg)
        reloadButton.isHidden = true
        isHidden = false
    
        successImageView.isHidden = true
    }
    
    func stopLoadingWithMessageNoLocalization(msg: String) {
        activityIndicator.stopAnimating()
        setMessageTextNoLocalization(msg)
        reloadButton.isHidden = true
        isHidden = false
        
        successImageView.isHidden = true
    }
    
    func stopLoadingWithError(msg: String) {
        activityIndicator.stopAnimating()
        setMessageText(msg)
        reloadButton.isHidden = false
        isHidden = false
    
        successImageView.isHidden = true
    }
    
    func stopLoadingWithErrorNoLocalization(msg: String) {
        activityIndicator.stopAnimating()
        setMessageTextNoLocalization(msg)
        reloadButton.isHidden = false
        isHidden = false
    
        successImageView.isHidden = true
    }
    
    func setMessageText(_ text: String!) {
        if text == nil || text == "" {
            message = ""
            messageLabel.text = ""
            messageLabel.isHidden = true
        }
    }
    
    func setMessageTextNoLocalization(_ text: String?) {
        if text == nil || text == "" {
            message = ""
            messageLabel.text = ""
            messageLabel.isHidden = true
        } else {
            message = text
            messageLabel.text = text
            messageLabel.isHidden = false
        }
    }
    
    @IBAction func reloadButtonTapped(_ sender: UIButton) {
        delegate?.reload()
    }
}
