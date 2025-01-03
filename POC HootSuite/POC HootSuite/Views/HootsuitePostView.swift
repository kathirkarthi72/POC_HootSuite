//
//  HootsuitePostView.swift
//  My Social Post
//
//  Created by Kathiresan on 03/01/25.
//

import SwiftUI
import YPImagePicker

struct HootsuitePostView: View {
    
    @ObservedObject private var viewModel = HootsuiteViewModel()
    @State private var isPhotoPickerPresented = false
    
    var body: some View {
        
        VStack {
            
            if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
//                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onTapGesture {
                        // Open image picker
                        isPhotoPickerPresented.toggle()
                    }
            } else {
                Image(uiImage: UIImage(named: "AddPhoto")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
//                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onTapGesture {
                        // Open image picker
                        isPhotoPickerPresented.toggle()
                    }
            }
           
            TextField("Enter your post", text: $viewModel.post)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                viewModel.postAllSocialMedia()
            }, label: {
                Text("Post to all social media")
            })
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $isPhotoPickerPresented) {
            YPImagePickerView(isPresented: $isPhotoPickerPresented, selectedImage: $viewModel.selectedImage)
        }
    }
}

#Preview {
    HootsuitePostView()
}
