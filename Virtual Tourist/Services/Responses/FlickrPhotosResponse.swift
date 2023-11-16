//
//  FlickrPhotosResponse.swift
//  Virtual Tourist
//
//  Created by Khoa Lê on 16/11/2023.
//

import Foundation

struct FlickrPhotosResponse: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
