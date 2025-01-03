//
//  HootSuiteService.swift
//  My Post
//
//  Created by Kathiresan on 23/12/24.
//

import Foundation
import SwiftUICore


class HootsuiteService {
    private let baseURL = Constants.baseURL
    private let clientId = Constants.clientId
    private let clientSecret = Constants.clientSecret
    var accessToken: String = ""
    
    @EnvironmentObject var auth: AuthVM

    func authenticate(completion: @escaping (Bool) -> Void) {
        // Example: Fetch the access token
        let tokenURL = "\(baseURL)/oauth2/token"
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        let body = "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)"
        request.httpBody = body.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["access_token"] as? String {
                    self.auth.authToken = token
                    self.auth.loggedIn = true
                    print("Access Token: \(self.auth.authToken)")
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }

    func fetchScheduledPosts(completion: @escaping ([String]?) -> Void) {
//        let accessToken = accessToken
        
        let url = "\(baseURL)/v1/messages/scheduled"
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print(json ?? [:])
                let messages = json?["data"] as? [[String: Any]]
                let titles = messages?.compactMap { $0["title"] as? String }
                completion(titles)
            } catch {
                completion(nil)
            }
        }.resume()
    }



// MARK: - Media Upload and Post Creation - Facebook
    func uploadMedia(imageData: Data, completion: @escaping (String?) -> Void) {
//        guard let accessToken = token else {
//            
//            print("Access token missed.")
//            return }
        
        let accessToken = auth.authToken

        let url = URL(string: "https://platform.hootsuite.com/v1/media")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let httpRes = response as? HTTPURLResponse {
                print("Status code: \(httpRes.statusCode)")
                                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let mediaId = json["id"] as? String
                        completion(mediaId)
                    } else {
                        completion("Error: failed.")
                    }
                } catch DecodingError.keyNotFound(let key, let error) {
                    print("Decoing error: \(key), \(error)")
                }  catch DecodingError.dataCorrupted(let error) {
                    print("Decoing error: \(error)")
                } catch DecodingError.valueNotFound(let key, let error) {
                    print("Decoing error: \(key), \(error)")
                } catch DecodingError.typeMismatch(let key, let error) {
                    print("Decoing error: \(key), \(error)")
                } catch {
                    print("Error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func createPost(accessToken: String? = nil, text: String, mediaId: String = "", facebookProfileId: String, completion: @escaping (Bool) -> Void) {
        guard let accessToken = accessToken else { return }
        let url = URL(string: "https://platform.hootsuite.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "text": text,
            "socialProfileIds": [facebookProfileId],
            "memberId": "987654321"
//            "media": [mediaId]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error {
                print("error: \(error.localizedDescription)")
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                print((response as? HTTPURLResponse)?.statusCode)
                
                if let data {
                    let respo = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    print(respo)
                }
                
                completion(false)
            }
            
           
        }.resume()
    }

}


// MARK: - Media Upload and Post Creation - Twitter
extension HootsuiteService {
   
    /* func uploadMedia(imageData: Data, completion: @escaping (String?) -> Void) {
        guard let accessToken = accessToken else { return }
        let url = URL(string: "https://platform.hootsuite.com/v1/media")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let mediaId = json["id"] as? String {
                completion(mediaId)
            } else {
                completion(nil)
            }
        }.resume()
    }
*/
    
    func createPost(text: String, mediaId: String, twitterProfileId: String, completion: @escaping (Bool) -> Void) {
        let accessToken = auth.authToken
        
        let url = URL(string: "https://platform.hootsuite.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "text": text,
            "socialProfileIds": [twitterProfileId],
            "media": [mediaId]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

}


// MARK: - Media Upload and Post Creation - LinkedIn
extension HootsuiteService {
    /*
    func uploadMedia(imageData: Data, completion: @escaping (String?) -> Void) {
        guard let accessToken = accessToken else { return }
        let url = URL(string: "https://platform.hootsuite.com/v1/media")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let mediaId = json["id"] as? String {
                completion(mediaId)
            } else {
                completion(nil)
            }
        }.resume()
    }
    */
    
    func createPost(text: String, mediaId: String, linkedInProfileId: String, completion: @escaping (Bool) -> Void) {
        let accessToken = auth.authToken
        let url = URL(string: "https://platform.hootsuite.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "text": text,
            "socialProfileIds": [linkedInProfileId],
            "media": [mediaId]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }


}

// MARK: - Media Upload and Post Creation - Instagram
extension HootsuiteService {
   /*
    func uploadMedia(imageData: Data, completion: @escaping (String?) -> Void) {
        guard let accessToken = accessToken else { return }
        let url = URL(string: "https://platform.hootsuite.com/v1/media")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let mediaId = json["id"] as? String {
                completion(mediaId)
            } else {
                completion(nil)
            }
        }.resume()
    }
*/
    
    func createPost(text: String, mediaId: String, instagramProfileId: String, completion: @escaping (Bool) -> Void) {
        
        let accessToken = auth.authToken
        let url = URL(string: "https://platform.hootsuite.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "text": text,
            "socialProfileIds": [instagramProfileId],
            "media": [mediaId]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

    
}

// MARK: - Media Upload and Post Creation - All Platforms
extension HootsuiteService {
    
    func createPost(text: String, mediaId: String, allSocialMediaProfileIds: [String] = Constants.allSocialMediaProfileId, completion: @escaping (Bool) -> Void) {
        let accessToken = auth.authToken
        let url = URL(string: "https://platform.hootsuite.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "text": text,
            "socialProfileIds": allSocialMediaProfileIds,
            "media": [mediaId]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
}
