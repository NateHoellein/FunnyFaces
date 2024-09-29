//
//  FunnyFacesApp.swift
//  FunnyFaces
//
//  Created by Nate on 9/27/24.
//

import SwiftUI
import PhotosUI

@main
struct FunnyFacesApp: App {
    @StateObject private var photoPickerViewModel = PhotoPickerViewModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                NavigationView {
                    TabView {
                        FunnyFaceView(faceViewModel: FacesViewmodel(photosViewModel: photoPickerViewModel))
                            .tabItem{
                                Label("Faces", systemImage:"face.dashed.fill")
                            }
    
                        CameraView()
                            .tabItem{
                                Label("Camera", systemImage: "camera")
                            }
                    }
                    
                }.navigationTitle("FUNNY FACES")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            PhotosPicker(
                                selection: $photoPickerViewModel.selectedPickerItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .imageScale(.large)
                            }
                        }
                    }
            }
        }
    }
}

