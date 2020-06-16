//
//  FlickerViewModel.swift
//  FlickerMobile
//
//  Created by Singh, Ranjeet Kumar on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import Foundation
/**
 View model class for the Flicker
 */

class FlickerViewModel {
    //Data model object
    var searchText: Observable<String> = Observable("")
    private var flicker: Flicker? = nil
    var isLoadingData: Observable<Bool> = Observable(false)
    var hasError: Observable<Bool> = Observable(false)
    var itemCount: Int { return self.cellViewModels.value.count }
    var searchCriteria = SearchTerm(text: "")
    private let serviceManager: FlickerServiceManager
    var screenTitle: Observable<String> = Observable("Flicker")
    var coordinater: MainCoordinater?
    private(set) var scrollToTop = Observable(false)
    /**
     This will initialized by service manager by dependency injection.
     */
    init(_ serviceManager: FlickerServiceManager = FlickerServiceManager()) {
        self.serviceManager = serviceManager
        dataBinder()
    }
    
    /**
     This is collection view cell model to represent data. It is obsevable, so any changes in list will reload collection view.
     */
    private(set) var cellViewModels: Observable<[FlickerItemViewModel]> = Observable([])
    
    /**
     This will construct view model for the cell
     */
    private func cellViewModelFor(photos: [Photo]) -> [FlickerItemViewModel]  {
        let items = photos.map { (photo) -> FlickerItemViewModel in
            return FlickerItemViewModel(photo)
        }
        return items
    }
    
    /**
     This will is data binder for the user query.
     */
    private func dataBinder() {
        self.searchText.bind { (text) in
            self.searchCriteria.text = text
            self.screenTitle.value = "Flicker(\(text))"
            self.searchCriteria.page = 0
            self.makeFlickerRequestFor(searchCriteria: self.searchCriteria)
        }
    }
    
    /**
     This will make request to load next page of the flicker api.
     */
    func loadNextPage() {
        if (self.searchCriteria.page + 1) <= (flicker?.photos?.pages ?? 0) {
            self.searchCriteria.page += 1
            self.makeFlickerRequestFor(searchCriteria: self.searchCriteria)
        }
        
    }
    
    /**
     This will make request to load search text by user and pagination.
     */
    private func makeFlickerRequestFor(searchCriteria: SearchTerm) {
        isLoadingData.value = true
        serviceManager.flickerRequest(searchCriteria) {[weak self] (result) in
            self?.isLoadingData.value = false
            switch result {
            case .success(let f):
                let cellItems = self?.cellViewModelFor(photos: f.photos?.photo ?? []) ?? []
                
                if let page = self?.self.searchCriteria.page, page == 0 // it is new search. so we have to replace old search result
                {
                    self?.flicker = f
                    self?.cellViewModels.value = cellItems
                } else {
                    self?.flicker?.photos?.photo?.append(contentsOf: f.photos?.photo ?? [])
                    self?.cellViewModels.value.append(contentsOf: cellItems)
                }
                self?.hasError.value = (self?.itemCount ?? 0) <= 0
            case .failure( _):
                self?.hasError.value = true
            }
        }
    }
}




