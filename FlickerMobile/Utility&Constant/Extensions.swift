//
//  Utility.swift
//  FlickerMobile
//
//  Created by Singh, Ranjeet Kumar on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import Foundation
import UIKit

/**
 Extension to the Collection view cell for getting identifire. Assuming name of the class and specified identifire of cell will be same.
 */
extension UICollectionViewCell
{
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nibName: String {
        return String(describing: self)
    }
}
