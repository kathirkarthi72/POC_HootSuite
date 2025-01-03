//
//  HootsuiteViewModel.swift
//  My Social Post
//
//  Created by Kathiresan on 03/01/25.
//

import Foundation
import SwiftUI

class HootsuiteViewModel: ObservableObject {
//    @Published var isAuthenticated = false
    @Published var scheduledPosts: [String] = []
    
    @Published var post = ""
    @Published var selectedImage: UIImage?
    
    let service = HootsuiteService()
    
    private var accessToken: String = ""
    
    func authenticate() {
        service.authenticate { success in
            DispatchQueue.main.async {
                print("logged in")
                //                self.isAuthenticated = success
            }
        }
    }
    
    func fetchScheduledPosts(_ token: String) {
        self.accessToken = token
        self.service.accessToken = token
        
        service.fetchScheduledPosts { posts in
            DispatchQueue.main.async {
                self.scheduledPosts = posts ?? []
            }
        }
    }
    
    func postFB() {
        guard let imageData = self.selectedImage?.jpegData(compressionQuality: 0.8) else { return }

        // Step 1: Upload Media
        service.uploadMedia(imageData: imageData) { mediaId in
            guard let mediaId = mediaId else {
                print("Failed to upload media")
                return
            }
            
            print("Media ID: \(mediaId)")
            // Step 2: Create Post
            self.service.createPost(
                text: "Check out this amazing image!",
                mediaId: mediaId,
                facebookProfileId: "<your_facebook_profile_id>"
            ) { success in
                if success {
                    print("Post created successfully!")
                } else {
                    print("Failed to create post")
                }
            }
        }
    }
    
    func createFBpost() {
        // Step 2: Create Post
        self.service.createPost(
            text: "Check out this amazing image!",
            mediaId: "",
            facebookProfileId: Constants.facebookProfileId
        ) { success in
            if success {
                print("Post created successfully!")
            } else {
                print("Failed to create post")
            }
        }
    }
    
    func postTwitter() {
        let imageData = UIImage(named: "yourImageName")!.jpegData(compressionQuality: 0.8)!

        // Step 1: Upload Media
        service.uploadMedia(imageData: imageData) { mediaId in
            guard let mediaId = mediaId else {
                print("Failed to upload media")
                return
            }
            
            // Step 2: Post to Twitter
            self.service.createPost(
                text: "Check out this image on Twitter!",
                mediaId: mediaId,
                twitterProfileId: "<your_twitter_profile_id>"
            ) { success in
                if success {
                    print("Post created successfully!")
                } else {
                    print("Failed to create post")
                }
            }
        }

    }
    
    func postLinkedIn() {
        let imageData = UIImage(named: "yourImageName")!.jpegData(compressionQuality: 0.8)!
        
        // Step 1: Upload Media
        service.uploadMedia(imageData: imageData) { mediaId in
            guard let mediaId = mediaId else {
                print("Failed to upload media")
                return
            }
            
            // Step 2: Post to LinkedIn
            self.service.createPost(
                text: "Excited to share this update on LinkedIn!",
                mediaId: mediaId,
                linkedInProfileId: "<your_linkedin_profile_id>"
            ) { success in
                if success {
                    print("Post created successfully!")
                } else {
                    print("Failed to create post")
                }
            }
        }
        
    }
    
    func postInstagram() {
        let imageData = UIImage(named: "yourImageName")!.jpegData(compressionQuality: 0.8)!
        
        // Step 1: Upload Media
        self.service.uploadMedia(imageData: imageData) { mediaId in
            guard let mediaId = mediaId else {
                print("Failed to upload media")
                return
            }
            
            // Step 2: Post to Instagram
            self.service.createPost(
                text: "Check out this image on Instagram!",
                mediaId: mediaId,
                instagramProfileId: "<your_instagram_profile_id>"
            ) { success in
                if success {
                    print("Post created successfully!")
                } else {
                    print("Failed to create post")
                }
            }
        }
        
    }
    
    func postAllSocialMedia() {
        createFBpost()
//        postFB()
//        postTwitter()
//        postLinkedIn()
//        postInstagram()
    }
}
