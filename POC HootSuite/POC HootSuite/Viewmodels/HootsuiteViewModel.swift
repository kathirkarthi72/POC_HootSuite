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
    
    var accessToken: String = ""
    
    func authenticate() async throws -> String? {
        try await service.authenticate()
    }
    
    func fetchScheduledPosts() {        
        service.fetchScheduledPosts { posts in
            DispatchQueue.main.async {
                self.scheduledPosts = posts ?? []
            }
        }
    }
    
    func fetchMember() {
        print("fetch member")
        
        Task {
            do {
                let members = try await self.service.fetchMember()
                print(members ?? [])
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchOrganization() async {
        print("Fetch Organization")
        
        do {
            let success = try await self.service.fetchOrganization()
            
            if success {
                print("Organization fetched successfully!")
            } else {
                print("Failed to get Organizationt")
            }
        } catch {
            print("Error: on Organization.")
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
    /*
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
    */
    func postTextInTwitter() async {
        do {
            let success = try await self.service.createPost(text: "Check out text on Twitter!", mediaId: "", twitterProfileId: Constants.twitterProfileId)
            
            if success {
                print("Post created successfully!")
            } else {
                print("Failed to create post")
            }
        } catch {
            print("Error: on Posting to X.")
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
    
    func postAllSocialMedia() async {
//        createFBpost()
//        postFB()
        
//        postLinkedIn()
//        postInstagram()
        
        await postTextInTwitter()
    }
}
