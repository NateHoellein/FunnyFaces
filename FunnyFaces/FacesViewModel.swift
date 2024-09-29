//
//  FacesViewModel.swift
//  FunnyFaces
//
//  Created by Nate on 9/28/24.
//

import SwiftUI
import Vision

class FacesViewmodel: ObservableObject {
    @Published var errorMessages: String? = nil
    @Published var photosViewModel: PhotoPickerViewModel
    
    init(photosViewModel: PhotoPickerViewModel) {
        self.photosViewModel = photosViewModel
    }
    
    @MainActor func detectFaces() {
        
        guard let image = photosViewModel.selectedImage else {
            DispatchQueue.main.async {
                self.errorMessages = "Could not load image"
            }
            return
        }
        
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                self.errorMessages = "Could not convert image to cgImage"
            }
            return
        }
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessages = error.localizedDescription
                }
                return
            }
            
            
            let rectangles: [CGRect] = request.results?.compactMap { rectangle in
                guard let observation = rectangle as? VNFaceObservation else { return nil }
                return observation.boundingBox
            } ?? []
            
            DispatchQueue.main.async {
                self?.errorMessages = rectangles.isEmpty ? "No faces detected : (" : nil
            }
            
            let updatedImage = self?.drawVisionRect(on: image, visionRects: rectangles)
            
            DispatchQueue.main.async { [self] in
                self?.photosViewModel.selectedImage = updatedImage
            }
        }
        
#if targetEnvironment(simulator)
        faceDetectionRequest.usesCPUOnly = true
#endif
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([faceDetectionRequest])
        } catch {
            DispatchQueue.main.async {
                self.errorMessages = "Failed to perform detection: \(error.localizedDescription)"
            }
        }
    }
    
    func drawVisionRect(on image: UIImage?, visionRects: [CGRect]) -> UIImage? {
        guard let image = image, let cgImage = image.cgImage else {
            return nil
        }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, image.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: imageSize))
        
        for rect in visionRects {
            let correctedRect = VNImageRectForNormalizedRect(rect, Int(imageSize.width), Int(imageSize.height))

            UIColor.red.withAlphaComponent(0.3).setFill()
            let rectPath = UIBezierPath(rect: correctedRect)
            rectPath.fill()
            
            UIColor.red.setStroke()
            rectPath.lineWidth = 2.0
            rectPath.stroke()
        }
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        print("original orientation is \(String(describing: newImage?.imageOrientation.rawValue))")
        
        UIGraphicsEndImageContext()
        let correctlyOrientedImage = UIImage(cgImage: newImage!.cgImage!, scale: image.scale, orientation: adjustOrientation(orient: image.imageOrientation))
        
        print("final orientation \(correctlyOrientedImage.imageOrientation.rawValue)")
        
        return correctlyOrientedImage
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
