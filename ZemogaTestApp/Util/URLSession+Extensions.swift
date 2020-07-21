//
//  URLSession+Extensions.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/25/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation
import UIKit

protocol DecodableTask {
    func doDecodeTask<T>(_ type: T.Type, from url: URL, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable
}

extension URLSession: DecodableTask {
    
    enum JsonError: Error {
        case noDataError
        case parsingError
    }
    
    enum ImageError: Error {
        case noDataError
        case creationError
    }
    
    enum NetworkError: Error, CustomStringConvertible {

        case unexpectedError
        case noDataError
        case otherError(error: Error)
        case decodeError(error: Error)
        case statusError(code: Int)
        
        var description: String {
            switch self {
            case .unexpectedError:
                return "Unexpected Network Error"
            case .noDataError:
                return "Empty Response Error"
            case .otherError(let error):
                return "Unhandled Network Error: (\(error.localizedDescription))"
            case .decodeError(let error):
                return "Network Decode Error: \(error.localizedDescription)"
            case .statusError(let code):
                return "HTTP Network Error: \(code)"
            }
        }
    }
    
    func doDecodeTask<T>(_ type: T.Type, from url: URL, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard error == nil else {
                completion(.failure(NetworkError.otherError(error: error ?? NetworkError.unexpectedError)))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                let error = NetworkError.statusError(code: response.statusCode)
                completion(.failure(error))
                return
            }
            
            guard let content = data else {
                completion(.failure(NetworkError.noDataError))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: content)
                completion(.success(result))
            } catch {
                completion(.failure(NetworkError.decodeError(error: error)))
            }
            
        })
        task.resume()
    }

    func doJsonTask(forURL endpoint: URL, completion: @escaping (_ data: [String: Any]?, _ error: Error?) -> Void ) {
        
        let task = URLSession.shared.dataTask(with: endpoint) {(data, response, error ) in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let content = data else {
                completion(nil, JsonError.noDataError)
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                completion(nil, JsonError.parsingError)
                return
            }
            
            completion(json, nil)
            
        }
        
        task.resume()
        
    }
    
    func createImageTask(fromURL imageURL: URL, completion: @escaping (UIImage?, Error?) -> Void ) -> URLSessionTask {
        
        let task = URLSession.shared.dataTask(with: imageURL) {(data, response, error ) in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let imageData = data else {
                completion(nil, ImageError.noDataError)
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                completion(nil, ImageError.creationError)
                return
            }
            
            completion(image, nil)
            
        }
        
        return task
        
    }
    
    func doImageTask(fromURL imageURL: URL, completion: @escaping (UIImage?, Error?) -> Void ) {
        
        let task = createImageTask(fromURL: imageURL, completion: completion)
        task.resume()
        
    }
}

extension UIStoryboard {
    
    static let main = UIStoryboard(name: "Main", bundle: nil)
    
}

