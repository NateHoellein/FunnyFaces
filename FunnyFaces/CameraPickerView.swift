//
//  CameraPickerView.swift
//  FunnyFaces
//
//  Created by Nate on 9/27/24.
//

import SwiftUI
import AVFoundation

class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
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
}

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var showCameraPicker = false
    
    var body: some View {
        VStack {
            if let image = viewModel.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("No image captured")
            }
            
            Button(action: {
                switch viewModel.cameraPermissionStatus {
                case .notDetermined:
                    viewModel.requestCameraPermissions()
                case .authorized:
                    showCameraPicker = true
                default:
                    break
                }
            }) {
                Text("Capture Photo")
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $viewModel.capturedImage)
            }
            Text(permissionMessage)
                .padding()
        }
        .onAppear {
            viewModel.checkCameraPermissions()
        }
    }
    
    private var permissionMessage: String {
        switch viewModel.cameraPermissionStatus {
        case .notDetermined:
            return ""
        case .restricted, .denied:
            return "Camera permission denied, go to Settings to enable it."
        case .authorized:
            return "Camera permission authorized"
        @unknown default:
            return ""
        }
    }
}

#Preview {
    CameraView()
}
