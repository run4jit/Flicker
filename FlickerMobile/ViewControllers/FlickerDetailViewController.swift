//
//  FlickerDetailViewController.swift
//  FlickerMobile
//
//  Created by Ranjeet Singh on 16/06/20.
//  Copyright © 2020 Ranjeet Singh. All rights reserved.
//

import UIKit

class FlickerDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var ownerLable: UILabel!
    @IBOutlet weak var serverLable: UILabel!

    var viewModel: Observable<FlickerItemViewModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBinder()
        // Do any additional setup after loading the view.
    }
    
    func viewBinder() {
        viewModel.bindAndFire {[weak self] (item) in
            item.itemImage.bindAndFire { (image) in
                self?.imageView.image = image
            }
            item.item.bindAndFire { (photo) in
                self?.titleLable.text = photo.title
                self?.ownerLable.text = photo.owner
                self?.serverLable.text = photo.server
                self?.title = photo.title

            }
        }
    }

}
