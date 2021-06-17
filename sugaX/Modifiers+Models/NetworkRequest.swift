/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

struct NetworkRequest {
  enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
  }

  enum RequestError: Error {
    case invalidResponse
    case networkCreationError
    case otherError
    case sessionExpired
  }

  enum RequestType: Equatable {
    case codeExchange(code: String)
    case getRepos
    case getUser
    case signIn

    func networkRequest() -> NetworkRequest? {
      guard let url = url() else {
        return nil
      }
      return NetworkRequest(method: httpMethod(), url: url)
    }

    private func httpMethod() -> NetworkRequest.HTTPMethod {
      switch self {
      case .codeExchange:
        return .post
      case .getRepos:
        return .get
      case .getUser:
        return .get
      case .signIn:
        return .get
      }
    }

    private func url() -> URL? {
      switch self {
      case .codeExchange(let code):
        let queryItems = [
          URLQueryItem(name: "client_id", value: NetworkRequest.clientID),
          URLQueryItem(name: "client_secret", value: NetworkRequest.clientSecret),
          URLQueryItem(name: "code", value: code)
        ]
        return urlComponents(host: "sandbox-api.dexcom.com", path: "/v2/oauth2/token", queryItems: queryItems).url
      case .getRepos:
        guard
          let username = NetworkRequest.username,
          !username.isEmpty
        else {
          return nil
        }
        return urlComponents(path: "/users/\(username)/repos", queryItems: nil).url
      case .getUser:
        return urlComponents(path: "/user", queryItems: nil).url
      case .signIn:
        let queryItems = [
          URLQueryItem(name: "client_id", value: NetworkRequest.clientID),
          URLQueryItem(name: "redirect_uris", value: "sugaX://callback/oauth"),
          URLQueryItem(name: "scope", value: "offline_access"),
          URLQueryItem(name: "response_type", value: "code"),
          URLQueryItem(name: "state", value: "randomstate01")
        ]

        return urlComponents(host: "sandbox-api.dexcom.com", path: "/v2/oauth2/login", queryItems: queryItems).url
      }
    }

    private func urlComponents(host: String = "sandbox-api.dexcom.com", path: String, queryItems: [URLQueryItem]?) -> URLComponents {
      switch self {
      default:
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        return urlComponents
      }
    }
  }

  typealias NetworkResult<T: Decodable> = (response: HTTPURLResponse, object: T)

  // MARK: Private Constants
  static let callbackURLScheme = "sugaX"
  static let clientID = "ppwU1wNLpASv7Xu1aalj4S4SGnNOuRKS"
  static let clientSecret = "sZLbOl82PGNJZJ6i"

  // MARK: Properties
  var method: HTTPMethod
  var url: URL

  // MARK: Static Methods
  static func signOut() {
    Self.accessToken = ""
    Self.refreshToken = ""
    Self.username = ""
  }

  // MARK: Methods
  func start<T: Decodable>(responseType: T.Type, completionHandler: @escaping ((Result<NetworkResult<T>, Error>) -> Void)) {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    if let accessToken = NetworkRequest.accessToken {
      request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    let session = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let response = response as? HTTPURLResponse else {
        DispatchQueue.main.async {
          completionHandler(.failure(RequestError.invalidResponse))
        }
        return
      }
      guard
        error == nil,
        let data = data
      else {
        DispatchQueue.main.async {
          let error = error ?? NetworkRequest.RequestError.otherError
          completionHandler(.failure(error))
        }
        return
      }

      if T.self == String.self, let responseString = String(data: data, encoding: .utf8) {
        let components = responseString.components(separatedBy: "&")
        var dictionary: [String: String] = [:]
        for component in components {
          let itemComponents = component.components(separatedBy: "=")
          if let key = itemComponents.first, let value = itemComponents.last {
            dictionary[key] = value
          }
        }
        DispatchQueue.main.async {
          NetworkRequest.accessToken = dictionary["access_token"]
          NetworkRequest.refreshToken = dictionary["refresh_token"]
          // swiftlint:disable:next force_cast
          completionHandler(.success((response, "Success" as! T)))
        }
        return
      } else if let object = try? JSONDecoder().decode(T.self, from: data) {
        DispatchQueue.main.async {
          if let user = object as? User {
            NetworkRequest.username = user.login
          }
          completionHandler(.success((response, object)))
        }
        return
      } else {
        DispatchQueue.main.async {
          completionHandler(.failure(NetworkRequest.RequestError.otherError))
        }
      }
    }
    session.resume()
  }
}
