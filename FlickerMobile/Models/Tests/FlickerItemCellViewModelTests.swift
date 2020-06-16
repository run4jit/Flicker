//
//  FlickerItemCellViewModelTests.swift
//  FlickerMobileTests
//
//  Created by Ranjeet Singh on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import XCTest
import Foundation
@testable import FlickerMobile

class FlickerItemCellViewModelTests: BaseFlickerTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testCellItem() {
        //{"id":"32848687068","owner":"24354425@N03","secret":"91d7a62796","server":"7818","farm":8,"title":"Butting Heads","ispublic":1,"isfriend":0,"isfamily":0}
        let photo = Photo(id: "32848687068", owner: "24354425@N03", secret: "91d7a62796", server: "7818", farm: 8, title: "Butting Heads", ispublic: 1, isfriend: 0, isfamily: 0)
        let imageMockSession = MockURLSession()
        
        imageMockSession.data = self.dataFromContaintOf(file: "cat1", type: "png")
        let expectedFirstCellViewModel = FlickerItemViewModel(photo, serviceManager: FlickerServiceManager(session: imageMockSession))
        
        setupMockupSessionWith(file: "FlickerTestData", ofType: "json")
        let flickerViewModel = FlickerViewModel(FlickerServiceManager(session: mockSession))
        
        let exp = self.expectation(description: "Success Full Load Mock Data")
        
        flickerViewModel.cellViewModels.bind { (cellViewModels:[FlickerItemViewModel]) in
            XCTAssertEqual(cellViewModels.count, 99, "Cell must have 99 items.")
            let firstItem = cellViewModels.first
            XCTAssertNotNil(firstItem)
            XCTAssertEqual(expectedFirstCellViewModel, firstItem)
            exp.fulfill()
        }
        
        expectedFirstCellViewModel.item.bind { (photo) in
            XCTAssertEqual(photo.title, "Butting Heads")
        }
        
        expectedFirstCellViewModel.itemImage.bind { (image) in
            XCTAssertNotNil(image)
        }
        
        expectedFirstCellViewModel.loadImage()

        flickerViewModel.searchText.value = "kittens"
        
        
        self.waitForExpectations(timeout: 15) { (errro) in
            XCTAssertNotNil("It has taken more than expected time to exequte.")
        }
    }

}
