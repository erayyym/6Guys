//
//  gptapi.swift
//  PocketLedger
//
//  Created by myr on 2024/3/18.
//

import Foundation

class OpenAI {
    private let apiKey = "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"
    private let session = URLSession.shared
    
    func ask(question: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://api.openai.com/v1/completions"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo-instruct",
            "prompt": question,
            "max_tokens": 70,
//            "temperature": 0.7
        ]
        
        do {
                    let requestData = try JSONSerialization.data(withJSONObject: body, options: [])
                    request.httpBody = requestData
                } catch {
                    print("Error: Could not encode JSON")
                    completion(nil)
                    return
                }
                
        session.dataTask(with: request) { data, response, error in
            // First, check for a network error
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Then, check the HTTP response and print out the status code
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    // If status code is not 200, there might be some problem
                    // Print the response body to get more clues
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Response Body: \(responseBody)")
                    }
                    completion(nil)
                    return
                }
            }

            // Handle the response data
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            // Try to decode the data into the OpenAIResponse structure
            do {
                let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let text = response.choices.first?.text {
                    DispatchQueue.main.async {
                        completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("JSON Decoding Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
            }
        }

// Response struct to decode the JSON response
struct OpenAIResponse: Codable {
    let choices: [Choice]
    struct Choice: Codable {
        let text: String
    }
}
