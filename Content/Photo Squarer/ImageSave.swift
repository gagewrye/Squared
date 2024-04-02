//
//  ImageSave.swift
//  Photo Squarer
//
//  Created by Dillan Wrye on 6/26/23.
//
// Save image with save(image)

import UIKit
func save(_ savedImage: UIImage?) {
    if let image = savedImage{
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
