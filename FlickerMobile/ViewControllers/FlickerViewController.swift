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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: FlickerItemCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: FlickerItemCollectionViewCell.identifier)
        viewModel = FlickerViewModel()
        viewModelBinder()
        // initial search
        viewModel.searchText.value = "kittens"
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
    }
}

//MARK: - Collection view data source and delegates implementations
extension FlickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickerItemCollectionViewCell.identifier, for: indexPath) as? FlickerItemCollectionViewCell else { return UICollectionViewCell() }
        cell.viewModel.value = viewModel.cellViewModels.value[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // loading next page
        if (viewModel.itemCount - 1) <= indexPath.item && !viewModel.isLoadingData.value {
            viewModel.loadNextPage()
        }
    }
}


extension FlickerViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 120)
    }
}

//MARK: - Collection view data source prefetch method implementations
extension FlickerViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // prefetching images
        for index in indexPaths {
            if index.item < self.viewModel.itemCount {
                let cellViewModel = self.viewModel.cellViewModels.value[index.item]
                cellViewModel.loadImage()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for index in indexPaths {
            // cancel prefetched image request
            if index.item < self.viewModel.itemCount {
                let cellViewModel = self.viewModel.cellViewModels.value[index.item]
                cellViewModel.cancelImageTask()
            }
        }
    }
}

//MARK: - Search bar delegates implementations
extension FlickerViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let text = searchBar.text ?? ""
        if viewModel.searchText.value != text {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            viewModel.searchText.value = text
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}




