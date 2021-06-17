/// Copyright (c) 2021 Razeware LLC
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

import AuthenticationServices
import OAuthSwift
import SwiftUI

class SignInViewModel: NSObject, ObservableObject {
    @Published var isShowingRepositoriesView = false
    @Published private(set) var isLoading = false
    
    let oauthswift = OAuth2Swift(
        consumerKey:    "ppwU1wNLpASv7Xu1aalj4S4SGnNOuRKS",
        consumerSecret: "sZLbOl82PGNJZJ6i",
        authorizeUrl:   "https://sandbox-api.dexcom.com/v2/oauth2/login",
        accessTokenUrl: "https://sandbox-api.dexcom.com/v2/oauth2/token",
        responseType:   "code"
    )
    
    func signInWithOAuthSwiftTapped() {
        // OAuthSwift
        var hasError = false
        OAuth2Swift.setLogLevel(.trace)
        
        let handle = oauthswift.authorize(
            withCallbackURL: "sugaX://callback/oauth",
            scope: "offline_access",
            state:"State01") { result in
            switch result {
            case .success(let (credential, response, parameters)):
                print(credential.oauthToken)
                print(parameters.count)
                //responses = "TOKEN: \(credential.oauthToken)"
                //access_token = credential.oauthToken
                //getEgvs(token: credential.oauthToken)
                
            case .failure(let error):
                hasError = true
                //errorMessage = error.localizedDescription
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    
    
    
    func signInTapped() {
        
        guard let signInURL =
                NetworkRequest.RequestType.signIn.networkRequest()?.url
        else {
            print("Could not create the sign in URL.")
            return
        }
        
        let callbackURLScheme = NetworkRequest.callbackURLScheme
        let authenticationSession = ASWebAuthenticationSession(
            url: signInURL,
            callbackURLScheme: callbackURLScheme) { [weak self] callbackURL, error in
            // 1
            guard
                error == nil,
                let callbackURL = callbackURL,
                // 2
                let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems,
                // 3
                let code = queryItems.first(where: { $0.name == "code" })?.value,
                // 4
                let networkRequest =
                    NetworkRequest.RequestType.codeExchange(code: code).networkRequest()
            else {
                // 5
                print("An error occurred when attempting to sign in.")
                return
            }
            
            self?.isLoading = true
            networkRequest.start(responseType: String.self) { result in
                switch result {
                case .success:
                    self?.getUser()
                case .failure(let error):
                    print("Failed to exchange access code for tokens: \(error)")
                    self?.isLoading = false
                }
            }
        }
        
        authenticationSession.presentationContextProvider = self
        authenticationSession.prefersEphemeralWebBrowserSession = true
        
        if !authenticationSession.start() {
            print("Failed to start ASWebAuthenticationSession")
        }
    }
    
    func appeared() {
        // Try to get the user in case the tokens are already stored on this device
        getUser()
    }
    
    private func getUser() {
        isLoading = true
        
        NetworkRequest
            .RequestType
            .getUser
            .networkRequest()?
            .start(responseType: User.self) { [weak self] result in
                switch result {
                case .success:
                    self?.isShowingRepositoriesView = true
                case .failure(let error):
                    print("Failed to get user, or there is no valid/active session: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
    }
}

extension SignInViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession)
    -> ASPresentationAnchor {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}
