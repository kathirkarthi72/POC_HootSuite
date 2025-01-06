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

    func authenticate() async throws -> String? {
        
        // Example: Fetch the access token
        let tokenURL = "\(baseURL)/oauth2/token"
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        
        let body = "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)"
        request.httpBody = body.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        if httpResponse.statusCode == 200, let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("Success. http Status: \(httpResponse.statusCode) Json: \(json)")
            
            if let token = json["access_token"] as? String {
                return token
            } else {
                return nil
            }
        } else {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("Failed. http Status: \(httpResponse.statusCode) Json: \(json)")
            return nil
        }
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
    
    func fetchOrganization() async throws -> Bool {
        let organizationid = "CHANGEPOND, Siruseri, Chennai"
//        organizations/:organizationId/teams
        let url = "\(baseURL)/v1/organizations/:\(organizationid)/teams"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("json: \(json)")
            
            if let status = response as? HTTPURLResponse {
                if status.statusCode == 200 {
                    print("fetchOrganization. Success Code: \(status.statusCode)")
                    return true
                } else {
                    print("fetchOrganization. Failure Code: \(status.statusCode)")
                }
            }
            return false
        } else {
            print("json Could not found.")
            return false
        }
        
    }
    
    func fetchMember() async throws -> [String]? {
        let url = "\(baseURL)/v1/me"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
//        self.validate(response: response, data: data) { result in
//            if let result {
//                return [result]
//            } else {
//                nil
//            }
//        }
        
        if let httpRes = response as? HTTPURLResponse {
            print("Status code: \(httpRes.statusCode)")
                            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print(json)
                    if let mediaId = json["id"] as? String {
                        return [mediaId]
                    } else {
                        return nil
                    }
                     
                } else {
                    print("Error: failed.")
                    return nil
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
                return nil
            }
        }
        
        return nil
    }


// MARK: - Media Upload and Post Creation - Facebook
    func uploadMedia(imageData: Data, completion: @escaping (String?) -> Void) {
//        guard let accessToken = token else {
//            
//            print("Access token missed.")
//            return }
        
        let accessToken = accessToken

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
            
            self.validate(response: response, data: data, completion: completion)
            
//            if let httpRes = response as? HTTPURLResponse {
//                print("Status code: \(httpRes.statusCode)")
//                                
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                        let mediaId = json["id"] as? String
//                        completion(mediaId)
//                    } else {
//                        completion("Error: failed.")
//                    }
//                } catch DecodingError.keyNotFound(let key, let error) {
//                    print("Decoing error: \(key), \(error)")
//                }  catch DecodingError.dataCorrupted(let error) {
//                    print("Decoing error: \(error)")
//                } catch DecodingError.valueNotFound(let key, let error) {
//                    print("Decoing error: \(key), \(error)")
//                } catch DecodingError.typeMismatch(let key, let error) {
//                    print("Decoing error: \(key), \(error)")
//                } catch {
//                    print("Error: \(error.localizedDescription)")
//                    completion(nil)
//                }
//            }
        }.resume()
    }
    
    func validate(response: URLResponse?, data: Data, completion: @escaping (String?) -> Void) {
        if let httpRes = response as? HTTPURLResponse {
            print("Status code: \(httpRes.statusCode)")
                            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print(json)
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
    
    func createPost(text: String, mediaId: String, twitterProfileId: String) async throws -> Bool {
        let accessToken = accessToken
        print("Access Token: \(accessToken)")
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
        
        
        let result = try await startPostTask(request: request)
        
        return result
        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }.resume()
    }
    
    func startPostTask(request: URLRequest) async throws -> Bool {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("json: \(json)")
            
            if let status = response as? HTTPURLResponse {
                if status.statusCode == 200 {
                    print("startPostTask. Success Code: \(status.statusCode)")
                    return true
                } else {
                    print("startPostTask. Failure Code: \(status.statusCode)")
                }
            }
            return false
        } else {
            print("json Could not found.")
            return false
        }
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
        let accessToken = accessToken
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
        
        let accessToken = accessToken
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
        let accessToken = accessToken
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
