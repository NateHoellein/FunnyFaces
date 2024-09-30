//
//  FunnyFaceView.swift
//  FunnyFaces
//
//  Created by Nate on 9/28/24.
//

import SwiftUI
import PhotosUI

struct FunnyFaceView: View {
    @StateObject var faceViewModel: FacesViewmodel
    
    var body: some View {
        VStack {
            if let image = faceViewModel.photosViewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding()
            } else {
                Text("No image selected")
                    .padding()
            }
            PhotosPicker(
                selection: $faceViewModel.photosViewModel.selectedPickerItem,
                    matching: .images,
                    photoLibrary: .shared()
                  ) {
                    Text("Select Photo")
                      .padding()
                      .background(Color.blue)
                      .foregroundColor(.white)
                      .cornerRadius(10)
                  }
            
            Button("Detect Faces") {
                faceViewModel.detectFaces()
            }
            .disabled(faceViewModel.photosViewModel.selectedImage == nil)
            if let errorMessage = faceViewModel.errorMessages {
              Text(errorMessage)
                .foregroundColor(.red)
                .padding()
            }
        }
    }
}

#Preview {
    FunnyFaceView(faceViewModel: FacesViewmodel(photosViewModel: PhotoPickerViewModel()))
}
