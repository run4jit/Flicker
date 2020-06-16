//
//  FlickerServiceManager.swift
//  FlickerMobile
//
//  Created by Singh, Ranjeet Kumar on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import Foundation
import UIKit

/**
 This is genaric enum which has associated values on success & failure responses.
 */
enum ResponseResult<T> {
    case success(_ response: T)
    case failure(_ error: Error?)
}

/**
 This service manager is resposible to makeing request and recived processed response.
 It initialized depends on the Session to make request. So we can use Mock Session for tesing.
 It will store the image in imageCache object with url as key.
 */
class FlickerServiceManager {
    private var imageCache = NSCache<NSString, UIImage>()
    private var session: URLSession
    private var copySession: URLSession // same session object can not be used, if we invalidateAndCancel. So I have copy of session which will use for reassigning.
    //Dependency injection of URLSession used to actual network call and mock call for testing
    init(session: URLSession = URLSession.shared) {
        self.session = session
        copySession = session.copy() as! URLSession
    }
    
    /**
     Flicker request is resposible to  request for search tearm and pagination.
     - Parameter search: Search term is used to get the Flicker data and pagination.
     - Parameter recievedResponse: Processed responsed came from server and pass to the clouser with success or failure.
     */
   
    func flickerRequest(_ search: SearchTerm , recievedResponse: @escaping(ResponseResult<Flicker>) -> Void) {
        //custruct URL
        var str = String("\(baseURL)/rest/?method=flickr.photos.search&api_key=\(apiKey)&format=json&nojsoncallback=1&safe_search=1&text=\(search.text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")
        
        str += ((search.page > 0) ? "&page=\(search.page)" : "&page=1")

        guard let url = URL(string: str) else {
            recievedResponse(.failure(nil))
            return
        }
        //Cancel all task
        self.cancelAllTask()
        // remove all image from image cache for diffrent text
        if search.page <= 0  {
            imageCache.removeAllObjects()
        }
        //Request for the fliker data
        self.session.codableTask(with: url) { (flicker: Flicker?, response, error) in
            if let flicker = flicker {
                recievedResponse(.success(flicker))
            } else {
                recievedResponse(.failure(error))
            }
        }.resume()
    }
    
    /**
     This will make request for the photo to get the image from constructed url.
     - Parameter photo: Search term is used to get the Flicker data and pagination.
     - Parameter recievedResponse: Processed responsed came from server and pass to the clouser with success or failure.
     */
    func loadImageFor(photo: Photo, recievedResponse: @escaping(ResponseResult<UIImage?>) -> Void) -> URLSessionDataTask? {
        guard let url = photo.photoURL else { recievedResponse(.failure(nil))
            return nil
        }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            recievedResponse(.success(cachedImage))
            return nil
        } else {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
            let task = self.session.dataTask(with: request) { (data, responce, error) in
                guard let data = data, error == nil else {
                    recievedResponse(.failure(error))
                    return
                }
                guard let image = UIImage(data: data) else {
                    recievedResponse(.failure(error))
                    return
                }
                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                recievedResponse(.success(image))
                }
                task.resume()
            return task
        }
    }

    
    /**
     This will cancel all request which ever has made.
     - Note: Upload task will not be canceled. Only data task and upload task will be canceled.
     */
    func cancelAllTask() {
        session.invalidateAndCancel()
        session = copySession.copy() as! URLSession
    }
}



// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? JSONDecoder().decode(T.self, from: data), response, nil)
        }
    }
}


// MARK: - Mock Session for testing
class MockURLSessionDataTask: URLSessionDataTask {
    private let callBack: ()->Void
    var cancelCallBack: (()->Void)?
    init(callBack: @escaping ()->Void) {
        self.callBack = callBack
    }
    override func resume() {
        callBack()
    }
    
    override func cancel() {
        cancelCallBack?()
    }
}

class MockURLSession: URLSession {
    var data: Data?
    var error: Error?
    
    override init() {
        super.init()
    }
    // Overriding data task function to exequte mock response
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {[weak self] in
            completionHandler(self?.data, nil, self?.error)
        }
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask { [weak self] in
            completionHandler(self?.data, nil, self?.error)
        }
    }
    
    override func invalidateAndCancel() {
        // Do nothing
    }
}
