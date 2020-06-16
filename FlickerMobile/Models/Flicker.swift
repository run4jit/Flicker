//
//  Flicker.swift
//  FlickerMobile
//
//  Created by Singh, Ranjeet Kumar on 13/01/19.
//  Copyright © 2019 Singh, Ranjeet Kumar. All rights reserved.
//

import Foundation

class SearchTerm {
    var text: String
    var page = 0
    
    init(text: String) {
        self.text = text
    }
}

struct Flicker: Codable {
    var photos: Photos?
    let stat: String?
}

struct Photos: Codable {
    let page, pages, perpage: Int?
    let total: String?
    var photo: [Photo]?
}

struct Photo: Codable, Equatable {
    let id, owner, secret, server: String?
    let farm: Int?
    let title: String?
    let ispublic, isfriend, isfamily: Int?
    
    var photoURL: URL? {
        guard let farm = self.farm, let server = self.server, let secret = self.secret, let id = self.id else {
            return nil
        }
        let strURL = "http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg"
        guard let url = URL(string: strURL) else {
            return nil
        }
        return url
    }
    
    public static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
            && lhs.owner == rhs.owner
            && lhs.secret == rhs.secret
            && lhs.server == rhs.server
            && lhs.farm == rhs.farm
            && lhs.title == rhs.title
            && lhs.ispublic == rhs.ispublic
            && lhs.isfriend == rhs.isfriend
            && lhs.isfamily == rhs.isfamily
    }
}


extension Photo {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Photo.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}




