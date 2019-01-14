//
//  FlickerViewModelTests.swift
//  FlickerMobileTests
//
//  Created by Ranjeet Singh on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import XCTest
import Foundation
@testable import FlickerMobile

class BaseFlickerTest: XCTestCase {
    let mockSession = MockURLSession()
    var bundle: Bundle!

    override func setUp() {
        bundle = Bundle(for: type(of: self))
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    
    func dataFromContaintOf(file: String, type: String) -> Data? {
        return getData(for: file, ofType: type, inBundle: bundle)
    }
    
    func setupMockupSessionWith(file: String, ofType: String) {
        mockSession.data = dataFromContaintOf(file: file, type: ofType)
    }
}

class FlickerViewModelTests: BaseFlickerTest {
    override func setUp() {
        super.setUp()
    }
    
    func testFlickerViewModel_successFullLoadMockData() {
        setupMockupSessionWith(file: "FlickerTestData", ofType: "json")
        let flickerViewModel = FlickerViewModel(FlickerServiceManager(session: mockSession))
        
        let exp = self.expectation(description: "Success Full Load Mock Data")

        flickerViewModel.cellViewModels.bind { (cellViewModels:[FlickerItemCellViewModel]) in
            XCTAssertEqual(cellViewModels.count, 99, "Cell must have 99 items.")
            let item = cellViewModels.first
            XCTAssertNotNil(item)
            exp.fulfill()
        }
        flickerViewModel.searchText.value = "kittens"


        self.waitForExpectations(timeout: 15) { (errro) in
            XCTAssertNotNil("It has taken more than expected time to exequte.")
        }
    }
    
    func testFlickerViewModel_failureForUnexpectedSearchResult() {
        
        setupMockupSessionWith(file: "UnexpenctedResponse", ofType: "txt")
        let flickerViewModel = FlickerViewModel(FlickerServiceManager(session: mockSession))
        
        let exp = self.expectation(description: "Failure For Unexpected Search Response")
        
        flickerViewModel.hasError.bind(listener: { (hasError) in
            XCTAssertEqual(hasError, true, "Search result must have error")
            exp.fulfill()
        })

        flickerViewModel.searchText.value = "wrong respnse data set"
        
        
        self.waitForExpectations(timeout: 15) { (errro) in
            XCTAssertNil(errro, "expecting error \(errro?.localizedDescription ?? "")")
        }
    }
    
}
