//
//  FlickerItemCellViewModel.swift
//  FlickerMobile
//
//  Created by Singh, Ranjeet Kumar on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import Foundation
import UIKit

/**
 View model class for the Flicker collectionViewCell item.
 */

class FlickerItemViewModel: Equatable {
    
    //Data model object
    var item: Observable<Photo>
    var itemImage: Observable<UIImage?> = Observable(nil)
    private var serviceManager: FlickerServiceManager
    private var task: URLSessionDataTask? = nil
    var coordinater: MainCoordinater?

    init(_ item: Photo, serviceManager: FlickerServiceManager = FlickerServiceManager()) {
        self.item = Observable(item)
        self.serviceManager = serviceManager
    }
    
    /**
     This will make request to load image from photo URL. Also keep a refrence of in memory images.
     */
    func loadImage() {
        if itemImage.value == nil {
            let photo = item.value
            task = serviceManager.loadImageFor(photo: photo) {[weak self] (result) in
                if let pUrl = photo.photoURL, let qUrl = self?.item.value.photoURL, pUrl == qUrl {
                    switch result {
                    case .success(let image):
                        self?.itemImage.value = image
                    case .failure( _):
                        self?.itemImage.value = nil
                    }
                }
                self?.task = nil
            }
        }
    }
    
    func cancelImageTask() {
        task?.cancel()
        task = nil
    }
    public static func == (lhs: FlickerItemViewModel, rhs: FlickerItemViewModel) -> Bool {
        return lhs.item.value == rhs.item.value
    }
}

