//
//  CustomSegue.swift
//  Scouting Bird
//
//  Created by Hasan S. Al-Bukhari on 2/19/17.
//  Copyright © 2017 IMENA. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {

    override func perform() {
        let sourceViewController: UIViewController = source
        let destinationViewController: UIViewController = destination
        
        sourceViewController.present(destinationViewController, animated: false, completion: nil)
    }
}
