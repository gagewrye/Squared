//
//  Square.swift
//  Photo Squarer
//
// These are the algorithms for squaring photos and videos
//
//  Created by Dillan Wrye on 6/26/23.
//

import UIKit
import SwiftUI
import CoreImage
import Foundation
import AVFoundation
import Photos

// TODO: Add metadata preservation
// TODO: make adjustable blur radius ??


func squareImage(image: UIImage, color: Color) -> UIImage? {
    let width = Int(image.size.width)
    let height = Int(image.size.height)
    if width == height {return image} // already square
    let size = max(width, height)
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, image.scale)
    guard let context = UIGraphicsGetCurrentContext() else {
        print("Error creating graphics context")
        return nil
    }
    
    if let cgColor = color.cgColor {
        context.setFillColor(cgColor)
    } else {
        print("Error unwrapping CGColor")
        return nil
    }
    context.fill(CGRect(x: 0, y: 0, width: size, height: size))
    
    let x: Int = (size - width) / 2
    let y: Int = (size - height) / 2
    
    image.draw(in: CGRect(x: x, y: y, width: width, height: height))
    
    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
        print("Error creating squared image")
        return nil
    }
    
    UIGraphicsEndImageContext()
    
    return newImage
}

func squareImage(image: UIImage, blurRegion: BlurRegion) -> UIImage? {
    let width = Int(image.size.width)
    let height = Int(image.size.height)
    if width == height {return image} // already square
    let size = max(width, height)
    
    
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, image.scale)
    guard UIGraphicsGetCurrentContext() != nil else {
        print("Error creating graphics context")
        return nil
    }
    
    let x: Int = (size - width) / 2
    let y: Int = (size - height) / 2
    var recWidth = x
    var recHeight = y
    var recOneX = x
    var recOneY = y
    var recTwoX = x
    var recTwoY = y
    
    // adjust size and location of cropped blur rectangle
    if width > height { // Wider than tall
        recWidth = width
        recOneY = 0
        recTwoY = size - y
    } else { // Taller than wide
        recHeight = height
        recOneX = 0
        recTwoX = width + recWidth // Set x to right side, add recwidth for the left buffer
    }
    
    // Draw the original image
    image.draw(in: CGRect(x: x, y: y, width: width, height: height))
    
    let topRect = CGRect(x: recOneX, y: recOneY, width: recWidth, height: recHeight)
    
    // Apply blur effect based on the blur region
    switch blurRegion {
    case .top:
        let bottomRect = CGRect(x: recTwoX, y: recTwoY, width: recWidth, height: recHeight)
        if let topImage = cropImage(image: image, rect: topRect) {
            if let blurredTopImage = applyGaussianBlur(image: topImage) {
                blurredTopImage.draw(in: topRect)
                blurredTopImage.draw(in: bottomRect)
            }
        }
    case .bottom:
        // Find where to crop
        var bottomRect : CGRect
        if height > width {
            bottomRect = CGRect(x: recTwoX - (2 * recWidth), y: recTwoY, width: recWidth, height: recHeight)
        } else {bottomRect = CGRect(x: recTwoX, y: height - y, width: recWidth, height: recHeight)}
        
        // draw both
        if let bottomImage = cropImage(image: image, rect: bottomRect) {
            if let blurredBottomImage = applyGaussianBlur(image: bottomImage) {
                blurredBottomImage.draw(in: topRect)
                bottomRect = CGRect(x: recTwoX, y: size - recHeight, width: recWidth, height: recHeight)
                blurredBottomImage.draw(in: bottomRect)
            }
        }
    case .both:
        // draw top / left image
        if let topImage = cropImage(image: image, rect: topRect) {
            if let blurredTopImage = applyGaussianBlur(image: topImage) {
                blurredTopImage.draw(in: topRect)
            }
        }
        
        // Find where to crop
        var bottomRect : CGRect
        if height > width {
            bottomRect = CGRect(x: recTwoX - (2 * recWidth), y: recTwoY, width: recWidth, height: recHeight)
        } else {bottomRect = CGRect(x: recTwoX, y: height - y, width: recWidth, height: recHeight)}
        
        // Draw bottom / right image
        if let bottomImage = cropImage(image: image, rect: bottomRect) {
            if let blurredBottomImage = applyGaussianBlur(image: bottomImage) {
                bottomRect = CGRect(x: recTwoX, y: size - recHeight, width: recWidth, height: recHeight)
                blurredBottomImage.draw(in: bottomRect)
            }
        }
    }
    
    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
        print("Error creating squared image")
        return nil
    }
    
    UIGraphicsEndImageContext()
    
    return newImage
}

func cropImage(image: UIImage, rect: CGRect) -> UIImage? {
    guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
    return UIImage(cgImage: cgImage)
}

func applyGaussianBlur(image: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    
    let filter = CIFilter(name: "CIGaussianBlur")
    filter?.setValue(ciImage, forKey: kCIInputImageKey)
    filter?.setValue(15, forKey: kCIInputRadiusKey) // Adjust the blur radius as needed
    
    guard let outputCIImage = filter?.outputImage else { return nil }
    
    let context = CIContext(options: nil)
    guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
    
    return UIImage(cgImage: outputCGImage)
}

func applyBoxBlur(image: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    
    let filter = CIFilter(name: "CIBoxBlur")
    filter?.setValue(ciImage, forKey: kCIInputImageKey)
    filter?.setValue(15, forKey: kCIInputRadiusKey) // Adjust the blur radius as needed
    
    guard let outputCIImage = filter?.outputImage else { return nil }
    
    let context = CIContext(options: nil)
    guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
    
    return UIImage(cgImage: outputCGImage)
}



enum BlurRegion {
    case top
    case bottom
    case both
}


// Video Squaring Logic


func squareVideo(url: URL, color: Color) async throws -> URL {
    try await requestPhotoLibraryAccess()
    let asset = AVAsset(url: url)
    let videoTrack = try await asset.loadTracks(withMediaType: .video).first
    
    guard let clipVideoTrack = videoTrack else {
        throw NSError(domain: "Video track not found", code: 1, userInfo: nil)
    }
    
    let squareSize = try await max(clipVideoTrack.load(.naturalSize).width, clipVideoTrack.load(.naturalSize).height)
    let duration = try await asset.load(.duration)
    
    // Create a background video track with the specified color
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
    do {
        try await createBlankVideo(duration: duration, outputURL: outputURL, size: CGSize(width: squareSize, height: squareSize), color: color)
        print("Created video at \(outputURL)")
    } catch {
        print("Failed to create video: \(error)")
    }
    let backgroundTrack = try await loadTrack(fromURL: outputURL)

    // Overlay the original video track on the background video track
    let composition = AVMutableComposition()
    let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    try await compositionVideoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.load(.duration)), of: backgroundTrack, at: .zero)
    try await compositionVideoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.load(.duration)), of: clipVideoTrack, at: .zero)
    
    // Export the composition to a new URL
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentDirectory = URL(fileURLWithPath: path)
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    let date = dateFormatter.string(from: Date())
    let saveURL = documentDirectory.appendingPathComponent("SquaredVideo-\(date).mov")
    
    guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
        throw NSError(domain: "Failed to create AVAssetExportSession", code: 2, userInfo: nil)
    }
    
    exporter.outputURL = saveURL
    exporter.outputFileType = AVFileType.mov
    
    await exporter.export()
    
    return saveURL
}


func createBlankVideo(duration: CMTime, outputURL: URL, size: CGSize, color: Color) async throws {
    let assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4)
    
    let outputSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: Int(size.width),
        AVVideoHeightKey: Int(size.height)
    ]
    
    let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
    
    assetWriter.add(writerInput)
    
    let bufferAttributes: [String: Any] = [
        kCVPixelBufferCGImageCompatibilityKey as String: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        kCVPixelBufferWidthKey as String: Int(size.width),
        kCVPixelBufferHeightKey as String: Int(size.height),
    ]
    
    let frameDuration = CMTime(value: 1, timescale: 30)
    let frameCount = Int(duration.seconds * Double(frameDuration.timescale))
    
    assetWriter.startWriting()
    assetWriter.startSession(atSourceTime: .zero)
    
    for i in 0..<frameCount {
        while !writerInput.isReadyForMoreMediaData {
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        
        var pixelBuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, bufferAttributes as CFDictionary, &pixelBuffer)
        
        if status != kCVReturnSuccess {
            throw NSError(domain: "Failed to create pixel buffer", code: Int(status), userInfo: nil)
        }
        
        guard let buffer = pixelBuffer else {
            throw NSError(domain: "Failed to create pixel buffer", code: 3, userInfo: nil)
        }
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer), width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.setFillColor(UIColor(color).cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: Int(size.width), height: Int(size.height)))
        
        let presentationTime = CMTime(value: Int64(i), timescale: frameDuration.timescale)
        if !adaptor.append(buffer, withPresentationTime: presentationTime) {
            throw NSError(domain: "Failed to append pixel buffer", code: 47, userInfo: nil)
        }
    }
    
    writerInput.markAsFinished()
    await assetWriter.finishWriting()
}

func loadTrack(fromURL url: URL) async throws -> AVAssetTrack {
    let asset = AVAsset(url: url)
    guard let track = try await asset.loadTracks(withMediaType: .video).first else {
        throw NSError(domain: "Failed to load track", code: 4, userInfo: nil)
    }
    return track
}

func requestPhotoLibraryAccess() async throws {
    let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    switch status {
    case .authorized:
        // User granted permission
        break
    case .limited:
        // User granted limited access
        break
    case .denied, .restricted:
        // User denied or restricted access
        throw NSError(domain: "Photo library access not granted", code: 10, userInfo: nil)
    case .notDetermined:
        // Authorization request not determined yet
        throw NSError(domain: "Photo library access request not determined", code: 11, userInfo: nil)
    @unknown default:
        // Unknown authorization status
        throw NSError(domain: "Unknown photo library authorization status", code: 12, userInfo: nil)
    }
}
