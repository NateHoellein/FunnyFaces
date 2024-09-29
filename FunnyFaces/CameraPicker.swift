//
//  CameraPicker.swift
//  FunnyFaces
//
//  Created by Nate on 9/27/24.
//

import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {


    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: CameraPicker
        
        init(parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
        
    @Binding var selectedImage: UIImage?
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
        
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
}
