//
//  ImageController.swift
//  ReGo
//
//  Created by Анна Мельхова on 11.05.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import Kingfisher

protocol ImageDelegate {

}

class ImageController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    var delegate : PlaceInfoController?
    var scale: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        backButton.setTitle(myKeys.image.back, for: .normal)
        
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        var image = delegate?.placeImage.image
        var imageWidth = image!.size.width
        var imageHeight = image!.size.height
        
        scale =  width / imageWidth
        
        
        scrollView.minimumZoomScale = scale!//CGFloat(minimumZoomScale)
        scrollView.maximumZoomScale = 10.0
        
        //scrollView.setZoomScale(scale!, animated: false)
        //imageView.frame.size = CGSize(width: width, height: height)

        imageView.image = image//?.resizeImage(targetSize: CGSize(width: width, height: height))

        //
        //imageView.frame.size = CGSize(width: width, height: height)
        //view.layoutIfNeeded()
        //scrollView.contentSize.width = width
        //scrollView.contentSize.height = height
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension UIImage {
  func resizeImage(targetSize: CGSize) -> UIImage {
    let size = self.size
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
}
