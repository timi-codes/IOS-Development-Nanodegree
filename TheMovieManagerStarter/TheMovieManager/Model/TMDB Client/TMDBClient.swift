//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

class TMDBClient {
    
    static let apiKey = "fbc30c1719e1ab12dfc7ab0b3257f5f5"

    struct Auth {
        fileprivate static var accountId = 0
        fileprivate static var requestToken = ""
        fileprivate static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let imageBaseUrl = "https://image.tmdb.org/t/p/w500"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case markWatchlist
        case markFavorite
        case search(String)
        case getFavorites
        case getRequestToken
        case login
        case createSessionId
        case webAuth
        case logout
        case posterImageURL(String)
        
        var stringValue: String {
            switch self {
                case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .getFavorites: return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                case .getRequestToken: return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
                case .login: return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
                case .createSessionId: return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
                case .webAuth: return "https://www.themoviedb.org/authenticate/" + Auth.requestToken + "?redirect_to=themoviemanager:authenticate"
                case .logout: return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
            case .search(let query): return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            case .markWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .markFavorite: return Endpoints.base + "/account/\(Auth.accountId)/favorite" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .posterImageURL(let posterPath): return Endpoints.imageBaseUrl + "/\(posterPath)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, completion: @escaping (Result<ResponseType, Error>) -> Void)-> URLSessionTask {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let tokenRequestResponse = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(tokenRequestResponse))
                }
            }catch {
                do {
                    let errorResponse = try decoder.decode(TMDBResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.failure(errorResponse))
                    }
                }catch {
                    DispatchQueue.main.async {
                       completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func taskForPostRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, completion: @escaping (Result<ResponseType, Error>)-> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try! JSONEncoder().encode(body)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            }catch {
                do {
                    let errorResponse = try JSONDecoder().decode(TMDBResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.failure(errorResponse))
                    }
                }catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
    
    class func logout(completion: @escaping () -> Void) {
        var urlRequest = URLRequest(url: Endpoints.logout.url)
        urlRequest.httpMethod = "DELETE"
        
        let body = LogoutRequest(sessionId: Auth.sessionId)
        urlRequest.httpBody = try! JSONEncoder().encode(body)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            Auth.requestToken = ""
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
    
    class func createSessionId(completion: @escaping (Bool, Error?) -> Void) {
        let postSession = PostSession(requestToken: Auth.requestToken)
        taskForPostRequest(url: Endpoints.createSessionId.url, body: postSession) { (result: Result<SessionResponse, Error>) in
            switch result {
            case .success(let successResponse):
                Auth.sessionId = successResponse.sessionId
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }

    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
       let loginRequest = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        taskForPostRequest(url: Endpoints.login.url, body: loginRequest) { (result: Result<RequestTokenResponse, Error>) in
           switch result {
           case .success(let successResponse):
               Auth.requestToken = successResponse.requestToken
               completion(true, nil)
           case .failure(let error):
               completion(false, error)
           }
       }
    }
    
    class func createRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getRequestToken.url) { (result: Result<RequestTokenResponse, Error>)  in
            switch result {
            case .success(let response):
                Auth.requestToken = response.requestToken
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getWatchlist.url) { (result: Result<MovieResults, Error>)   in
            switch result {
            case .success(let response):
                completion(response.results, nil)
            case .failure(let error):
                completion([], error)
            }
        }
    }
    
    class func getFavorites(completion: @escaping ([Movie], Error?)-> Void) {
        taskForGETRequest(url: Endpoints.getFavorites.url) { (result: Result<MovieResults, Error>) in
            switch result {
            case .success(let response):
                completion(response.results, nil)
            case .failure(let error):
                completion([], error)
            }
        }
    }
    
    class func search(query: String, completion: @escaping ([Movie], Error?)-> Void)-> URLSessionTask {
        let task = taskForGETRequest(url: Endpoints.search(query).url) { (result: Result<MovieResults, Error>) in
            switch result {
            case .success(let response):
                completion(response.results, nil)
            case .failure(let error):
                completion([], error)
            }
        }
        return task
    }
    
    class func markWatchlist(mediaId: Int, watchlist: Bool, completion: @escaping (Bool, Error?)->Void){
        let body = MarkWatchlist(mediaType: "movie", mediaId: mediaId, watchlist: watchlist)
        taskForPostRequest(url: Endpoints.markWatchlist.url, body: body) { (result: Result<TMDBResponse, Error>) in
            switch result {
            case .success(let response):
                completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
            case .failure(let error):
                print(error)
                completion(false, error)
            }
        }
    }
    
    class func markFavorite(mediaId: Int, favorite: Bool, completion: @escaping (Bool, Error?)->Void){
        let body = MarkFavorite(mediaType: "movie", mediaId: mediaId, favorite: favorite)
        taskForPostRequest(url: Endpoints.markFavorite.url, body: body) { (result: Result<TMDBResponse, Error>) in
            switch result {
            case .success(let response):
                completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
            case .failure(let error):
                print(error)
                completion(false, error)
            }
        }
    }
    
    class func downloadPosterImage(posterPath: String, completion: @escaping (Result<Data?, Error>) -> Void){
        let task = URLSession.shared.dataTask(with: Endpoints.posterImageURL(posterPath).url) { (data, response, error) in
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
        task.resume()
    }
    
}
