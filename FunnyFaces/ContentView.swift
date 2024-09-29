////
////  ContentView.swift
////  FunnyFaces
////
////  Created by Nate on 9/27/24.
////
//
//import SwiftUI
//import PhotosUI
//
//struct ContentView: View {
//    @StateObject private var photoPickerViewModel = PhotoPickerViewModel()
//    var body: some View {
//        NavigationView {
//            TabView {
//                PhotoPickerView(faceViewModel: FacesViewmodel(photosViewModel: PhotoPickerViewModel()))
//                    .tabItem{
//                        Label("Photos", systemImage:"photo.on.rectangle")
//                    }
//                
//                CameraView()
//                    .tabItem{
//                        Label("Camera", systemImage: "camera")
//                    }
//            }
//            
//        }.navigationTitle("FUNNY FACES")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    PhotosPicker(
//                        selection: $photoPickerViewModel.selectedPickerItem,
//                        matching: .images,
//                        photoLibrary: .shared()
//                    ) {
//                        Image(systemName: "photo.on.rectangle.angled")
//                            .imageScale(.large)
//                    }
//                }
//            }
//    }
//}
//
//#Preview {
//    ContentView()
//}
