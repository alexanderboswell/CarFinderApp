//
//  Extensions.swift
//  CarFinder
//
//  Created by alexander boswell on 6/22/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCacheWithURLString( urlString: String){
    
        self.image = UIImage(named: "Default Photo Placeholder")
        
        if  let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        } else {
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            print("there")
            if error != nil {
                print(error ?? "unknown value")
                return
            }
            DispatchQueue.main.async(execute: {
                if let downloadedImage = UIImage(data: data!) {
                    self.image = UIImage(data: data!)
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
                
            })
        }).resume()
       }
   }
}
