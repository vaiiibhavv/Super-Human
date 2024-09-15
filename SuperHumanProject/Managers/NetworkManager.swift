//
//  NetworkManager.swift
//  SuperHumanProject
//
//  Created by Vaibhav on 10/09/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

struct Constants {
    static let apiURL = "https://www.mysuperhumanrace-uat.com/api/liveFeedApis"
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func getApiItems(lastId: Int, completion: @escaping (Result<[String: Any], NetworkError>) -> Void) {
        guard let url = URL(string: "\(Constants.apiURL)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let jsonBody: [String: Any] = [
            "action": "get_live_feed",
            "data": [
                "limit": "10",
                "lastId": lastId
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) else {
            completion(.failure(.decodingError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let data = data, !data.isEmpty else {
                completion(.failure(.noData))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(.decodingError))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }
        task.resume()
    }
    
}
