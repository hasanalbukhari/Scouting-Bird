//
//  Common.swift
//  Scouting Bird
//
//  Created by Hasan S. Al-Bukhari on 2/20/17.
//  Copyright © 2017 IMENA. All rights reserved.
//

import UIKit

class Common: NSObject {

    class func setupBirdImageAnimationFor(imageView: UIImageView) {
        var birdImagesList: [UIImage] = []
        for postfix in 1...14 {
            birdImagesList.append(UIImage(named: "bird_\(postfix)")!)
        }
        
        imageView.image = nil
        imageView.animationImages = birdImagesList
        imageView.animationDuration = 1.0
        imageView.startAnimating()
    }
}
