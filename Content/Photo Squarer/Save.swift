//
//  SaveVideo.swift
//  Photo Squarer
//
//  Created by Dillan Wrye on 7/16/23.
//

import Foundation
import Photos
import UIKit

import Foundation
import Photos
import UIKit
    
func saveVideo(videoURL: URL, completion: @escaping (Bool, Error?) -> Void) {
    PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
    }) { saved, error in
        completion(saved, error)
    }
}

 func saveImage(_ savedImage: UIImage?) {
    if let image = savedImage{
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}


