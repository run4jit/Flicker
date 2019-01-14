//
//  Utility.swift
//  FlickerMobile
//
//  Created by Ranjeet Singh on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import Foundation

/**
 This function will return data of resource file from specified bundle else nil
 - Parameter file: file name
 - Parameter type: file type
 - Parameter bundle: It could be application or test bundle.
 - Returns: The data containting in file
 */
func getData(for file: String, ofType type: String, inBundle bundle: Bundle = Bundle.main) -> Data? {
    guard let path = bundle.path(forResource: file, ofType: type) else { return nil }
    let url = URL(fileURLWithPath: path)
    return try? Data(contentsOf: url)
}
