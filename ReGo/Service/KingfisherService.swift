//
//  KingfisherService.swift
//  ReGo
//
//  Created by Анна Мельхова on 04.06.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import Foundation
import Kingfisher

class KingfisherService {
    
    func imageFromDB(url : String) -> UIImage {
           let newimage = UIImageView()
           let url = URL(string: url)
           let resource = ImageResource(downloadURL: url!)
               
           newimage.kf.setImage(with: resource) { (image, error, cachType, url) in
                       if let error = error {
                           print(error)
                       }
                       else {
                           print("Success updated image in calout!")
                       }
                   }
           return newimage.image!
       }
}
