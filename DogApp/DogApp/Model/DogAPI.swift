//
//  DogApi.swift
//  DogApp
//
//  Created by Timi Tejumola on 10/04/2020.
//  Copyright © 2020 Timi Tejumola. All rights reserved.
//

import Foundation
import UIKit

class DogAPI {
    enum Endpoint {
        case randomImageFromAllDogsCollection
        case randowImageForBreed(String)
        case getAllBreeds
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
        
        var stringValue: String {
            switch self {
            case .randomImageFromAllDogsCollection:
                return "https://dog.ceo/api/breeds/image/random"
            case let .randowImageForBreed(breed):
                return "https://dog.ceo/api/breed/\(breed)/images/random"
            case .getAllBreeds:
                return "https://dog.ceo/api/breeds/list/all"
            }
        }
    }
    
    class func requestAllBreeds(completion: @escaping ([String], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoint.getAllBreeds.url) { (data, response, error) in
            guard let data = data else {
                completion([], error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let breedsResponse = try decoder.decode(BreedsResponse.self, from: data)
                
                let breeds = breedsResponse.message.keys.map({$0})
                completion(breeds, nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    class func requestRandomImage(url: URL, completion: @escaping (DogImage?, Error?) -> Void){
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
       
           do {
               let decoder = JSONDecoder()
               let dogImage = try decoder.decode(DogImage.self, from: data)
                completion(dogImage, nil)
           } catch {
               print(error.localizedDescription)
           }
        }
        task.resume()
    }
    
    class func requestImageFile(url: URL, completion: @escaping (UIImage?, Error?) -> Void){
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            let requestedImage = UIImage(data: data)
            completion(requestedImage, nil)
        }
        task.resume()
    }
    
    
}
