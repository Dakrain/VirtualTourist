//
//  FlickClient.swift
//  Virtual Tourist
//
//  Created by Khoa Lê on 16/11/2023.
//

import Foundation


class FlickrClient {
    static let apiKey = "7c518bbb2e3d1d9d87a6907305d8f129"
    
    static let photosPerPage = 12
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?api_key=\(FlickrClient.apiKey)&&format=json&nojsoncallback=1&"
        
        case search(String)
        case getSizes(String)
        
        var stringValue: String {
            switch self {
            case .search(let parameters): return Endpoints.base + "method=flickr.photos.search&per_page=\(FlickrClient.photosPerPage)&" + parameters
            case .getSizes(let parameters): return Endpoints.base + "method=flickr.photos.getSizes&" + parameters
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    class func getPhotos(lat : Double, lng: Double,page: Int, completion: @escaping (Photos?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.search("lat=\(lat)&lon=\(lng)&page=\(page)").url, responseType: FlickrPhotosResponse.self) { response, error in
            if let response = response  {
                completion(response.photos, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getSizes(photoId : String, completion: @escaping (Sizes?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getSizes("photo_id=\(photoId)").url, responseType: FlickrSizeResponse.self) { response, error in
            if let response = response  {
                completion(response.sizes, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func downloadImage(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let download = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        download.resume()
    }
    
    
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
//        print("Request Url:\(url)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            
            let decoder = JSONDecoder()
            
            if let responseString = String(data: data, encoding: .utf8) {
//                print("Response Data:\n\(responseString)")
            }
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
}
