//
//  UIImage+Helpers.swift
//  FunnyFaces
//
//  Created by Nate on 9/29/24.
//

import UIKit
import Vision

extension UIImage {

    
    func drawVisionRect(visionRects: [CGRect]) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: imageSize))
        
        for rect in visionRects {
            let vampire = UIImage(named: "vampire")
            let correctedRect = VNImageRectForNormalizedRect(rect, Int(imageSize.width), Int(imageSize.height))
            
            let adjustedVampire = UIImage(cgImage: vampire!.cgImage!, scale: vampire!.scale, orientation: adjustOrientation(orient: vampire!.imageOrientation))
            adjustedVampire.draw(in: correctedRect)
        }
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        print("original orientation is \(String(describing: newImage?.imageOrientation.rawValue))")
        
        UIGraphicsEndImageContext()
        let correctlyOrientedImage = UIImage(cgImage: newImage!.cgImage!, scale: self.scale, orientation: adjustOrientation(orient: self.imageOrientation))
        
        print("final orientation \(correctlyOrientedImage.imageOrientation.rawValue)")
        
        return correctlyOrientedImage
    }
    
    func drawEyes(faceData: [FaceData]?) -> UIImage? {
        print("Orientation: \(self.imageOrientation)")
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        guard let faceData = faceData else {
            return nil
        }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: imageSize))
    
        for facedata in faceData {
            
            let leftEyeRect = self.createRect(points: facedata.landmarks.leftEye!.normalizedPoints,
                                              boundingBox: facedata.faceBoundBox,
                                              imageSize: imageSize)
            print("Left eye \(leftEyeRect)")
            UIColor.yellow.setFill()
            let leftpath = UIBezierPath(ovalIn: leftEyeRect)
            
            leftpath.fill()
            UIColor.yellow.setStroke()
            leftpath.lineWidth = 2.0
            leftpath.stroke()
            leftpath.close()
            
            let leftPupalRect = self.createRect(points: facedata.landmarks.leftPupil!.normalizedPoints,
                                              boundingBox: facedata.faceBoundBox,
                                              imageSize: imageSize)
            let updatedLeftPupal = CGRect(x: leftPupalRect.minX,
                                          y: leftPupalRect.minY,
                                          width: leftEyeRect.width / 3,
                                          height: leftEyeRect.height / 3)
            print("Left pupal \(updatedLeftPupal)")
            UIColor.black.setFill()
            let leftPupalPath = UIBezierPath(ovalIn: updatedLeftPupal)
            
            leftPupalPath.fill()
            UIColor.black.setStroke()
            leftPupalPath.lineWidth = 2.0
            leftPupalPath.stroke()
            leftPupalPath.close()
            
            let rightEyeRect = self.createRect(points: facedata.landmarks.rightEye!.normalizedPoints,
                                              boundingBox: facedata.faceBoundBox,
                                              imageSize: imageSize)
            
            UIColor.white.setFill()
            let rightpath = UIBezierPath(ovalIn: rightEyeRect)
            
            rightpath.fill()
            UIColor.white.setStroke()
            rightpath.lineWidth = 2.0
            rightpath.stroke()
            rightpath.close()

            let rightPupalRect = self.createRect(points: facedata.landmarks.rightPupil!.normalizedPoints,
                                              boundingBox: facedata.faceBoundBox,
                                              imageSize: imageSize)
            let updatedRightPupal = CGRect(x: rightPupalRect.minX,
                                          y: rightPupalRect.minY,
                                          width: rightEyeRect.width / 3,
                                          height: rightEyeRect.height / 3)
            UIColor.black.setFill()
            let rightPupalPath = UIBezierPath(ovalIn: updatedRightPupal)
            
            rightPupalPath.fill()
            UIColor.black.setStroke()
            rightPupalPath.lineWidth = 1.0
            rightPupalPath.stroke()
            rightPupalPath.close()
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        print("NewImage Orientation: \(newImage!.imageOrientation)")
        let correctlyOrientedImage = UIImage(cgImage: newImage!.cgImage!,
                                             scale: self.scale,
                                             orientation: adjustOrientation(orient: self.imageOrientation))
        
        return correctlyOrientedImage
    }
    
    func createRect(points: [CGPoint], boundingBox: CGRect, imageSize: CGSize) -> CGRect {
        let minX = points.min { $0.x < $1.x }!.x
            let minY = points.min { $0.y < $1.y }!.y
            let maxX = points.max { $0.x < $1.x }!.x
            let maxY = points.max { $0.y < $1.y }!.y

            let minPoint = VNImagePointForFaceLandmarkPoint(
              vector_float2(Float(minX), Float(minY)),
              boundingBox,
              Int(imageSize.width),
              Int(imageSize.height))
            let maxPoint = VNImagePointForFaceLandmarkPoint(
              vector_float2(Float(maxX), Float(maxY)),
              boundingBox,
              Int(imageSize.width),
              Int(imageSize.height))
        let width = maxPoint.x - minPoint.x
        let height = maxPoint.y - minPoint.y
        
        if width > height {
            return CGRect(x: minPoint.x,
                          y: minPoint.y,
                          width: width,
                          height: width)
        } else {
            return CGRect(x: minPoint.x,
                          y: minPoint.y,
                          width: height,
                          height: height)
        }
    }

    func adjustOrientation(orient: UIImage.Orientation) -> UIImage.Orientation {
        switch orient {
        case .up: return .downMirrored
        case .upMirrored: return .up
            
        case .down: return .upMirrored
        case .downMirrored: return .down
            
        case .left: return .rightMirrored
        case .rightMirrored: return .left
            
        case .right: return .leftMirrored //check
        case .leftMirrored: return .right
            
        @unknown default: return orient
        }
    }
}
