//
//  UIButton.swift
//  AREarth
//
//  Created by Kamyar Sehati on 1/5/21.
//

import UIKit

extension UIButton {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
