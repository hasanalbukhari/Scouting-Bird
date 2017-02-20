//
//  ViewController.swift
//  Scouting Bird
//
//  Created by Hasan S. Al-Bukhari on 2/18/17.
//  Copyright © 2017 IMENA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var birdImageView: UIImageView!
    @IBOutlet weak var treeImageView: UIImageView!
    @IBOutlet weak var scoutButton: UIButton!
    
    @IBOutlet weak var verImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var horImageConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var horTreeImageConstraint: NSLayoutConstraint!
    
    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
     
        Log.info("Home controller loaded")
        
        // set bird animation sprite.
        Common.setupBirdImageAnimationFor(imageView: birdImageView)
        
        // hide scout button til animation finishes.
        scoutButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // animate tree in.
        animateTree()
    }
    
    // MARK: Actions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        // animate tree out before performing segue to next controller.
        animateTreeOut()
    }
    
    // MARK: Animation Methods
    func animateTree() {
        // set starting constant
        horTreeImageConstraint.constant = (treeImageView.frame.size.width + view.frame.size.width) / 2.0
        
        // layout views
        view.layoutIfNeeded()
        
        // set final constant
        horTreeImageConstraint.constant = 0
        
        // animate
        UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveLinear, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) -> Void in
            // animate bird out
            self.animateBirdOut()
        })
    }
    
    func animateBirdOut() {
        // layout views
        view.layoutIfNeeded()
        
        // set animation constants
        horImageConstraint.constant = (birdImageView.frame.size.width + view.frame.size.width) / 2.0
        verImageConstraint.constant = -view.frame.size.height * 0.07
        
        // animate
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveLinear, animations: { () -> Void in
        
            self.view.layoutIfNeeded()
                
        }, completion: { (finished: Bool) -> Void in
            // animate bird in
            self.animateBirdIn()
        })
    }
    
    func animateBirdIn() {
        // setup starting stat.
        birdImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        verImageConstraint.constant = -view.frame.size.height * 0.23
        
        // layout views
        view.layoutIfNeeded()
        
        // set animation constants
        horImageConstraint.constant = 0
        verImageConstraint.constant = -view.frame.size.height * 0.3
        
        // animate
        UIView.animate(withDuration: 2.0, delay: 0.2, options: .curveEaseOut, animations: { () -> Void in
                
            self.view.layoutIfNeeded()
                
        }, completion: { (finished: Bool) -> Void in
            self.scoutButton.isHidden = false
        })
    }
    
    func animateTreeOut() {
        // hide scout button.
        scoutButton.isHidden = true
        
        // layout views
        view.layoutIfNeeded()
        
        // set animation constants
        horTreeImageConstraint.constant = (treeImageView.frame.size.width + view.frame.size.width) / 2.0
        
        // animate
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveLinear, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) -> Void in
            // show to scout controller
            self.performSegue(withIdentifier: "ScoutSegue", sender: self)
        })
    }
}
