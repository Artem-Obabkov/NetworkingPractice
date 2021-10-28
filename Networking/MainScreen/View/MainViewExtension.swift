//
//  MainViewExtension.swift
//  Networking
//
//  Created by pro2017 on 08/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import UIKit

extension MainView {
    
    func createAlert() {
        
        let alert = UIAlertController(title: "Downloading...", message: "0%", preferredStyle: .alert)
        
        let height = NSLayoutConstraint(item: alert.view as Any,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 0,
                                        constant: 170)
        alert.view.addConstraint(height)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (alert) in
            self.dataProvider.stopDownload()
        }
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true) {
            
            // Activity indicator
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: alert.view.frame.width / 2 - size.width / 2, y: alert.view.frame.height / 2 - size.height / 2)
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            
            activityIndicator.color = .darkGray
            activityIndicator.startAnimating()
            
            alert.view.addSubview(activityIndicator)
            
            // Progress bar
            
            let progressBar = UIProgressView(frame: CGRect(x: 0, y: alert.view.frame.height - 44, width: alert.view.frame.width, height: 2))
            
            progressBar.tintColor = .blue
            
            alert.view.addSubview(progressBar)
            
            self.dataProvider.progressBar = { progress in
                progressBar.progress = Float(progress)
                alert.message = String(Int(progress * 100)) + "%"
            }
        }
    }
}
