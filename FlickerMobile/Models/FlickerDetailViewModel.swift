//
//  FlickerDetailViewModel.swift
//  FlickerMobile
//
//  Created by Ranjeet Singh on 16/06/20.
//  Copyright © 2020 Ranjeet Singh. All rights reserved.
//

import Foundation

class FlickerDetailViewModel {
    var photo: Observable<Photo>
    
    init(photo: Photo) {
        self.photo = Observable(photo)
    }
}
