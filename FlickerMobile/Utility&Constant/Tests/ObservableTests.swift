//
//  ObservableTests.swift
//  FlickerMobileTests
//
//  Created by Singh, Ranjeet Kumar on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import XCTest
@testable import FlickerMobile

class ObservableTests: XCTestCase {

    class TestObservable {
        let text: Observable<String>
        
        init(text: String) {
            self.text = Observable(text)
        }
    }
    
    var testObj: TestObservable?
    let initialValue = "Hi! initial Observable Value"
    override func setUp() {
        
        testObj = TestObservable(text: initialValue)
    }

    override func tearDown() {
        testObj = nil
    }

    func testObservableValue() {
        
        testObj?.text.bindAndFire { (text) in
            XCTAssertTrue(text == self.initialValue)
        }
        
        let newValue = "New Value"
        testObj?.text.bind { (text) in
            XCTAssertTrue(text == newValue)
        }
        
        testObj?.text.value = newValue
    }
    
    func testObservableObject() {
        let testObj1 = Observable(TestObservable(text: "initial value"))
        testObj1.bindAndFire() { (testObj) in
            XCTAssertFalse(testObj.text.value.isEmpty)
        }
        
        testObj1.bind { (testObj) in
            XCTAssertTrue(testObj.text.value == "Another value")
        }
        
        testObj1.value = TestObservable(text: "Another value")

    }

}
