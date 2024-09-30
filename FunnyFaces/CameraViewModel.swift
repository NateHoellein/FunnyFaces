//
//  CameraPickerView.swift
//  FunnyFaces
//
//  Created by Nate on 9/27/24.
//

import SwiftUI
import AVFoundation
import Vision

class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var errorMessages: String? = nil
    
    init() {
        checkCameraPermissions()
    }
    
    func checkCameraPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            self.cameraPermissionStatus = status
        }
    }
    
    func requestCameraPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            self.checkCameraPermissions()
        }
    }
    
    @MainActor func detectFaces() {
        
        guard let image = capturedImage else {
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
        
        let faceLandmarkRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessages = error.localizedDescription
                }
                return
            }

            let faceData: [FaceData]? = request.results?.compactMap({ request in
                if let observation = request as? VNFaceObservation,
                   let landmark = observation.landmarks {
                    let faceBoundingBox = observation.boundingBox
                    return FaceData(landmarks: landmark, faceBoundBox: faceBoundingBox)
                } else {
                    DispatchQueue.main.async {
                        self?.errorMessages = "No face landmarks detected"
                    }
                }
                return nil
            })
            
            DispatchQueue.main.async {
                self?.errorMessages = faceData?.isEmpty ?? false ? "No face landmarks detected : (" : nil
            }
            
            let updatedImage = image.drawEyes(faceData: faceData)
            
            DispatchQueue.main.async { [self] in
                self?.capturedImage = updatedImage
            }
        }
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessages = error.localizedDescription
                }
                return
            }
            
            
            let rectangles: [CGRect] = request.results?.compactMap { request in
                guard let observation = request as? VNFaceObservation else { return nil }
                return observation.boundingBox
            } ?? []
            
            
            DispatchQueue.main.async {
                self?.errorMessages = rectangles.isEmpty ? "No faces detected : (" : nil
            }
            
            let updatedImage = image.drawVisionRect(visionRects: rectangles)
            
            DispatchQueue.main.async { [self] in
                self?.capturedImage = updatedImage
            }
        }
        
#if targetEnvironment(simulator)
        faceDetectionRequest.usesCPUOnly = true
        faceLandmarkRequest.usesCPUOnly = true
#endif
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([faceLandmarkRequest])
        } catch {
            DispatchQueue.main.async {
                self.errorMessages = "Failed to perform detection: \(error.localizedDescription)"
            }
        }
    }
}


