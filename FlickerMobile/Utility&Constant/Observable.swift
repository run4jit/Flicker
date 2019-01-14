//
//  Observable.swift
//  FlickerMobile
//
//  Created by Singh, Ranjeet Kumar on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import Foundation


/**
 Objects of basic data types and values of primitive types provide us a way to observe their changes.
 We have to gain control of their setters and notify those who are interested. This is called wrapping or boxing of an object.
 It’s simple, yet powerful. It can work with any type, you can bind any logic you need and you don’t have to go the through pain of registering and unregistering observers (listeners).
 */
class Observable<T> {
    /**
     A closure which take generic object and return void.
     */
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    /**
     This function will call listener after seting new value.
     - Parameter listener: a closure which need to get called.
     */
    func bind(listener: Listener?) {
        self.listener = listener
    }
    
    /**
     This function will call, listener immediately after seting value.
     - Parameter listener: a closure which need to get called.
     */
    func bindAndFire(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    /**
     A generic class instance to become observable.
     */
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    /**
     Initialize Observable class with any instance which we want to observe
     - Parameter value: A generic class instance to become observable.
     */
    init(_ v: T) {
        value = v
    }
}

