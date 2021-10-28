//
//  UITextViewExtension.swift
//  Networking
//
//  Created by pro2017 on 14/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func setBottomBorder(with color: UIColor) {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.darkGray.cgColor

        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
      }
    
}
