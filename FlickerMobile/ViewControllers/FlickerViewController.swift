//
//  FlickerViewController.swift
//  FlickerMobile
//
//  Created by Singh, Ranjeet Kumar on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//
//
import UIKit

class FlickerViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    var viewModel: FlickerViewModel!
    private lazy var dataSourceAndDelegates = FlickerViewDataSourceAndDelegates(viewModel: viewModel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: FlickerItemCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: FlickerItemCollectionViewCell.identifier)
        viewModelBinder()
        // initial search
        viewModel.searchText.value = searchBar.text ?? "god"
        
        //Setup delegates & data source.
        searchBar.delegate = dataSourceAndDelegates
        collectionView.delegate = dataSourceAndDelegates
        collectionView.dataSource = dataSourceAndDelegates
    }
    
    func viewModelBinder() -> Void {
        // Observed for getting list of searched item from network call. Also update UI accordingly
        viewModel.isLoadingData.bind { (isLoading) in
            DispatchQueue.main.async {
                self.errorMessageLabel.isHidden = isLoading
                self.collectionView.isHidden = isLoading && self.viewModel.searchCriteria.page <= 0
                isLoading ? self.spinner.startAnimating() : self.spinner.stopAnimating()
                self.spinner.isHidden = !isLoading
            }
        }
        
        // Observed if any network error comes, also update UI accordingly.
        viewModel.hasError.bind { (hasError) in
            DispatchQueue.main.async {
                self.errorMessageLabel.isHidden = !hasError
                self.collectionView.isHidden = hasError
                self.spinner.isHidden = hasError
                
                self.errorMessageLabel.text = "\(NSLocalizedString("Sad Face", comment: "😒"))\n \"\(self.viewModel.searchCriteria.text)\" \(NSLocalizedString("Result Not Found!", comment: "Result Not Found!"))"
            }
        }
        
        // Observed if any data source changes, reload collection view.
        viewModel.cellViewModels.bind { (items) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        // Bind screen title with search text
        viewModel.screenTitle.bindAndFire { (text) in
            self.title = text
        }
        
        viewModel.scrollToTop.bind { (top) in
            if top {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
        }
    }
}




