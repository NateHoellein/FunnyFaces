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
    @StateObject private var cameraPickerViewModel = CameraViewModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                NavigationView {
                    TabView {
                        FunnyFaceView(faceViewModel: FacesViewmodel(photosViewModel: photoPickerViewModel))
                            .tabItem{
                                Label("Photos", systemImage:"photo.on.rectangle.angled")
                            }
    
                        GooglyEyesView(viewModel: cameraPickerViewModel)
                            .tabItem{
                                Label("Camera", systemImage: "camera")
                            }
                    }
                    
                }.navigationTitle("FUNNY FACES")
            }
        }
    }
}
