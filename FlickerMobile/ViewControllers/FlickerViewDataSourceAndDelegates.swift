//
//  FlickerViewDataSourceAndDelegates.swift
//  FlickerMobile
//
//  Created by Ranjeet Singh on 17/06/20.
//  Copyright © 2020 Ranjeet Singh. All rights reserved.
//

import Foundation
import UIKit

class FlickerViewDataSourceAndDelegates: NSObject {
    private weak var viewModel: FlickerViewModel?
    init(viewModel: FlickerViewModel) {
        self.viewModel = viewModel
        super.init()
    }
}


//MARK: - Collection view data source and delegates implementations
extension FlickerViewDataSourceAndDelegates: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return  0 }
        return viewModel.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickerItemCollectionViewCell.identifier, for: indexPath) as? FlickerItemCollectionViewCell, let viewModel = viewModel else { return UICollectionViewCell() }
        cell.viewModel.value = viewModel.cellViewModels.value[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // loading next page
        guard let viewModel = viewModel else { return }

        if (viewModel.itemCount - 1) <= indexPath.item && !viewModel.isLoadingData.value {
            viewModel.loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }

        viewModel.coordinater?.showFlickerDetail(viewModel: viewModel.cellViewModels.value[indexPath.item])

    }
}


extension FlickerViewDataSourceAndDelegates : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 120)
    }
}

//MARK: - Collection view data source prefetch method implementations
extension FlickerViewDataSourceAndDelegates: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let viewModel = viewModel else { return }

        // prefetching images
        for index in indexPaths {
            if index.item < viewModel.itemCount {
                let cellViewModel = viewModel.cellViewModels.value[index.item]
                cellViewModel.loadImage()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let viewModel = viewModel else { return }

        for index in indexPaths {
            // cancel prefetched image request
            if index.item < viewModel.itemCount {
                let cellViewModel = viewModel.cellViewModels.value[index.item]
                cellViewModel.cancelImageTask()
            }
        }
    }
}

//MARK: - Search bar delegates implementations
extension FlickerViewDataSourceAndDelegates: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let viewModel = viewModel else { return }

        searchBar.resignFirstResponder()
        let text = searchBar.text ?? ""
        if viewModel.searchText.value != text {
            viewModel.scrollToTop.value = true
            viewModel.searchText.value = text
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
