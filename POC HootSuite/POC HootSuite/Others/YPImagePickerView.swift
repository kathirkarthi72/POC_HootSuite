//
//  YPImagePickerView.swift
//  My Social Post
//
//  Created by Kathiresan on 03/01/25.
//


import SwiftUI
import YPImagePicker

struct YPImagePickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIViewController {
        var config = YPImagePickerConfiguration()
        
        // Customize the picker configuration
        config.screens = [.photo, .library]
        config.library.mediaType = .photo
        config.startOnScreen = .library
        config.hidesStatusBar = false
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 1 // Allow multiple selections
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [self] items, _ in
            if let photo = items.singlePhoto {
                self.selectedImage = photo.image
            }
            isPresented = false
            picker.dismiss(animated: true)
        }
        
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed for now
    }
}

//#Preview {
//    YPImagePickerView()
//}
