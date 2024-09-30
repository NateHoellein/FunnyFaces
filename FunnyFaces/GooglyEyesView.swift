//
//  GooglyEyesView.swift
//  FunnyFaces
//
//  Created by Nate on 9/28/24.
//

import SwiftUI

struct GooglyEyesView: View {
    @StateObject var viewModel: CameraViewModel
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
            Button("Detect Faces") {
                viewModel.detectFaces()
            }
            .disabled(viewModel.capturedImage == nil)
            if let errorMessage = viewModel.errorMessages {
              Text(errorMessage)
                .foregroundColor(.red)
                .padding()
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
    GooglyEyesView(viewModel: CameraViewModel())
}
