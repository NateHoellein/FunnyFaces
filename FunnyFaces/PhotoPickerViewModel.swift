//
//  PhotoPickerView.swift
//  FunnyFaces
//
//  Created by Nate on 9/27/24.
//

import SwiftUI
import PhotosUI

class PhotoPickerViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedPickerItem: PhotosPickerItem? {
        didSet {
            if let item = selectedPickerItem {
                loadImage(from: item)
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self.selectedImage = uiImage
                    } else {
                        print("Failed to load image")
                    }
                case .failure(let error):
                    print("Error loading image \(error)")
                }
            }
        }
    }
}
