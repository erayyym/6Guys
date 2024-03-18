//
//  UIImage+Extension.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/17.
//
import Foundation

import UIKit

extension UIImage {
    func resetImgSize(maxImageLength: CGFloat = 1024, maxSizeKB:CGFloat) -> Data?{
        var maxSize = maxSizeKB
        var maxImageSize = maxImageLength
        if (maxSize <= 0.0) {
            maxSize = 1024.0;
        }
        if (maxImageSize <= 0.0)  {
            maxImageSize = 1024.0;
        }
        var newSize = CGSize(width: size.width, height: size.height)
        if max(size.width, size.height) > maxImageSize{
            if size.width > size.height{
                newSize = CGSize(width: maxImageSize, height: maxImageSize * size.height / size.width)
            }
            if size.height > size.width{
                newSize = CGSize(width: maxImageSize * size.width / size.height, height: maxImageSize)
            }
            
        }
        UIGraphicsBeginImageContext(newSize)
        draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
    
        UIGraphicsEndImageContext()
        guard var imageData =  newImage?.jpegData(compressionQuality: 1.0) else {return nil}
        var sizeOriginKB : CGFloat = CGFloat((imageData.count)) / 1024.0;
        var resizeRate = 0.9;
        while (sizeOriginKB > maxSize && resizeRate > 0.1) {
            guard let data = newImage?.jpegData(compressionQuality: CGFloat(resizeRate)) else { return nil}
            imageData = data
            sizeOriginKB = CGFloat((imageData.count)) / 1024.0;
            resizeRate -= 0.1;
        }
        return imageData
    }
}
