//
//  Int.swift
//  AREarth
//
//  Created by Kamyar Sehati on 1/5/21.
//

import UIKit

extension Int {
    var toRadius: CGFloat {
        return CGFloat(self) * CGFloat.pi / 180
    }
}
