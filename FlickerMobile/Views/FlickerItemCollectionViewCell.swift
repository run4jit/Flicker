//
//  FlickerItemCollectionViewCell.swift
//  FlickerMobile
//
//  Created by Singh, Ranjeet Kumar on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import UIKit

class FlickerItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    var viewModel: Observable<FlickerItemCellViewModel?> = Observable(nil)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = ""
        itemImageView.image = nil
        viewModelBinder()
    }
    
    func viewModelBinder() {
        viewModel.bind { (model: FlickerItemCellViewModel?) in
            
            model?.item.bindAndFire(listener: {[weak self] (item: Photo) in
                DispatchQueue.main.async {
                    self?.titleLabel.text = item.title
                    self?.itemImageView.image = model?.itemImage.value
                    // Request for image if model does not have image
                    if self?.itemImageView.image == nil {
                        model?.loadImage()
                    }
                }
                
            })
            
            model?.itemImage.bind(listener: {[weak self] (image) in
                // Check image response which recieved for the same cell. Then update the UI.
                if let calledURL = model?.item.value.photoURL, let currentItemURL = self?.viewModel.value?.item.value.photoURL, calledURL == currentItemURL {
                    DispatchQueue.main.async {
                        self?.itemImageView.image = image
                    }
                }
            })
        }
    }
    
}

