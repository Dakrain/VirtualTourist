//
//  FlickrSizeResponse.swift
//  Virtual Tourist
//
//  Created by Khoa Lê on 16/11/2023.
//

import Foundation

struct FlickrSizeResponse: Codable {
    let sizes: Sizes
    let stat: String
}

struct Sizes: Codable {
    let canblog: Int
    let canprint: Int
    let candownload: Int
    let size: [PhotoSize]
}

struct PhotoSize: Codable {
    let label: String
    let width: Int
    let height: Int
    let source: String
    let url: String
    let media: String
}
