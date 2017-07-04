//
//  LoadingOverlay.swift
//  CarFinder
//
//  Created by alexander boswell on 6/28/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
class LoadingOverlay {
    
    static let instance = LoadingOverlay()
    
func showLoadingOverlay(message: String) -> UIAlertController {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
    return alert
    }
}
