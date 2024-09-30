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
            
            let transform = CGAffineTransform(scaleX: imageSize.width, y: -imageSize.height)
                .translatedBy(x: 0, y: -1)
                .scaledBy(x: facedata.faceBoundBox.width, y: facedata.faceBoundBox.height)
                .translatedBy(x: facedata.faceBoundBox.minX, y: facedata.faceBoundBox.minY)
            
            let leftEyePoints = facedata.landmarks.leftEye?.normalizedPoints.map { $0.applying(transform) }
            
            let leftEyeRect = self.createRectFromPoints(points: leftEyePoints!)
            
            UIColor.white.setFill()
            let leftpath = UIBezierPath(ovalIn: leftEyeRect)
            
            leftpath.fill()
            UIColor.white.setStroke()
            leftpath.lineWidth = 2.0
            leftpath.stroke()
            leftpath.close()
            
            let leftPupalPoints = facedata.landmarks.leftPupil?.normalizedPoints.map {$0.applying(transform)}
            let leftPupalRect = self.createRectFromPoints(points: leftPupalPoints!)
            
            UIColor.black.setFill()
            let leftPupalPath = UIBezierPath(ovalIn: leftPupalRect)
            
            leftPupalPath.fill()
            UIColor.black.setStroke()
            leftPupalPath.lineWidth = 2.0
            leftPupalPath.stroke()
            leftPupalPath.close()
            
            let rightEyePoints = facedata.landmarks.rightEye?.normalizedPoints.map { $0.applying(transform) }
            
            let rightEyeRect = self.createRectFromPoints(points: rightEyePoints!)
            
            UIColor.white.setFill()
            let rightpath = UIBezierPath(ovalIn: rightEyeRect)
            
            rightpath.fill()
            UIColor.white.setStroke()
            rightpath.lineWidth = 2.0
            rightpath.stroke()
            rightpath.close()

            let rightPupalPoints = facedata.landmarks.rightPupil?.normalizedPoints.map {$0.applying(transform)}
            let rightPupalRect = self.createRectFromPoints(points: rightPupalPoints!)
            
            UIColor.black.setFill()
            let rightPupalPath = UIBezierPath(ovalIn: rightPupalRect)
            
            rightPupalPath.fill()
            UIColor.black.setStroke()
            rightPupalPath.lineWidth = 2.0
            rightPupalPath.stroke()
            rightPupalPath.close()
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let correctlyOrientedImage = UIImage(cgImage: newImage!.cgImage!,
                                             scale: self.scale,
                                             orientation: adjustOrientation(orient: self.imageOrientation))
        
        return correctlyOrientedImage
    }

    func createRectFromPoints(points: [CGPoint]) -> CGRect {
        let minXPoint = points.min(by: {$0.x < $1.x})
        let minYPoint = points.min(by: {$0.y < $1.y})
        let maxXPoint = points.max(by: {$0.x < $1.x})
        let maxYPoint = points.max(by: {$0.y < $1.y})

        let width = maxXPoint!.x - minXPoint!.x
        let height = maxYPoint!.y - minYPoint!.y
        
        let rect = CGRect(origin: CGPoint(x: minXPoint!.x, y: minYPoint!.y),
                                size: CGSize(width: width, height: height))
        return rect
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
