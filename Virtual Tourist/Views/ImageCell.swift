//
//  ImageCell.swift
//  Virtual Tourist
//
//  Created by Khoa Lê on 16/11/2023.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var picture: PictureModel!
    
    func getSizes() {
        if let data = picture.data {
            imageView.image = UIImage(data: data)
        } else if let pictureId = picture.id {
            FlickrClient.getSizes(photoId: pictureId) { sizes, error in
                if let sizes = sizes {
                    if let url = sizes.size.first?.source  {
                        self.downloadImage(link: url)
                    }
                }
            }
        }
    }
    
    func downloadImage(link : String) {
        let url = URL(string: link)!
        FlickrClient.downloadImage(url: url) { data, error in
            if let data = data {
                self.imageView.image = UIImage(data: data)
                
                self.picture.data = data
                
//                try? DataController.shared.viewContext.save()
            }
        }
    }
}
