//
//  ContentView.swift
//  sugaX
//
//  Created by Nicolas Ott on 14.06.21.
//

import SwiftUI
import StoreKit
import OAuthSwift
import Combine

struct ContentView: View {
    
    @ObservedObject var settings: UserSettings
    @Environment (\.presentationMode) var presentationMode
    
    let productIDs = [
        "de.nicolasott.sugaX.premium"
    ]
    @StateObject var storeManager = StoreManager()
    @State var navSelected: Int? = nil
   
    // create an instance and retain it
    let oauthswift = OAuth2Swift(
        consumerKey:    "ppwU1wNLpASv7Xu1aalj4S4SGnNOuRKS",
        consumerSecret: "sZLbOl82PGNJZJ6i",
        authorizeUrl:   "https://sandbox-api.dexcom.com/v2/oauth2/login",
        accessTokenUrl: "https://sandbox-api.dexcom.com/v2/oauth2/token",
        responseType:   "code"
    )
    /* PROD
    let oauthswift = OAuth2Swift(
        consumerKey:    "ppwU1wNLpASv7Xu1aalj4S4SGnNOuRKS",
        consumerSecret: "sZLbOl82PGNJZJ6i",
        authorizeUrl:   "https://api.dexcom.com/v2/oauth2/login",
        accessTokenUrl: "https://api.dexcom.com/v2/oauth2/token",
        responseType:   "code"
    )
    */
    @State var hasError = false
    @State var errorMessage = ""
    @State var access_token = ""
    @State var responseDataString = ""
    @State private var results = [Evgs]()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                ScrollView {
                HStack {
                    //Spacer()
                    Text("Welcome SugaX Pal!").font(.title).foregroundColor(.primeInverted)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button(action: {
                        oauth2Login()
                    }) {
                        HStack {
                            Image(systemName: "lock").foregroundColor(Color.primeInverted)
                            Text("Login")
                           
                        }.padding().background(Color.white)
                    }.foregroundColor(.primeInverted)
                    Spacer()
                }
               
                    Text("Values: ").foregroundColor(.white)
                    Text("Value.count: \(results.count)").foregroundColor(.white)
                    /*
                    List(results, id: \.id) { item in
                               VStack(alignment: .leading) {
                                   Text("\(item.value)")
                                    .font(.headline).foregroundColor(.white)
                                  
                               }
                           }
                    */
                if hasError {
                    Spacer()
                    Spacer()
                    HStack {
                        Spacer()
                        
                            Image(systemName: "xmark").foregroundColor(Color.red)
                        VStack {
                            Text("ERROR").foregroundColor(.primeInverted)
                            Text(errorMessage).foregroundColor(.primeInverted)
                        }
                    }.padding().background(Color.white)
                  
                }
                
                
                
                NavigationLink(destination: SettingsView(settings: settings, storeManager: storeManager).accentColor(Color.prime)
                                .edgesIgnoringSafeArea(.bottom), tag: 1, selection: $navSelected)
                {
                    EmptyView()
                }.isDetailLink(false)
                
                NavigationLink(destination: EmptyView())
                {
                    EmptyView()
                }
                }
            }
            .background(Color.prime).edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle(loc_sugaX, displayMode: .automatic).allowsTightening(true)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    HStack {
                        Button(action: {
                            self.navSelected = 1
                        }) {
                            Image(systemName: "gearshape").foregroundColor(Color.prime)
                            
                        }
                    }
                }
                
            }
            
            .accentColor(Color.prime).edgesIgnoringSafeArea(.bottom)
            .onAppear(perform: {
                onAppear()
                UITabBar.appearance().backgroundColor = UIColor.systemBackground
                UITabBar.appearance().isTranslucent = true
            })
        }.accentColor(Color.prime).edgesIgnoringSafeArea(.bottom)
    }
    
    func onAppear() {
        
        // IAP
        SKPaymentQueue.default().add(storeManager)
        storeManager.getProducts(productIDs: productIDs)
        //settings.purchased = true
        UserDefaults(suiteName: "group.de.nicolasott.sugaX")!.set(settings.purchased, forKey: "purchased")
        
        // FIRST START or UPDATE
      
    }
    
   
    func oauth2Login() {
        hasError = false
        OAuth2Swift.setLogLevel(.trace)
        let handle = oauthswift.authorize(
            withCallbackURL: "sugaX://callback/",
            scope: "offline_access",
            state:"State01") { result in
            switch result {
            case .success(let (credential, response, parameters)):
                print(credential.oauthToken)
                print(parameters.count)
                //responses = "TOKEN: \(credential.oauthToken)"
                access_token = credential.oauthToken
                getEgvs(token: credential.oauthToken)
                
            case .failure(let error):
                hasError = true
                errorMessage = error.localizedDescription
                print(error.localizedDescription)
            }
        }
    }

    // SB User5
    /*
    Optional("{\"calibrations\":null,\"egvs\":{\"start\":{\"systemTime\":\"2018-02-22T08:18:10\",\"displayTime\":\"2018-02-22T00:18:10\"},\"end\":{\"systemTime\":\"2021-06-16T08:28:10\",\"displayTime\":\"2021-06-16T00:28:10\"}},\"events\":{\"start\":{\"systemTime\":\"2018-02-22T16:08:19.514\",\"displayTime\":\"2018-02-22T08:08:19.514\"},\"end\":{\"systemTime\":\"2021-06-16T01:53:46.457\",\"displayTime\":\"2021-06-15T17:53:46.457\"}}}")

    */
    
    
    
    func getEgvs(token: String) {
      
        let headers = [
          "authorization": "Bearer \(token)"
        ]
        let dataRange =  NSMutableURLRequest(url: NSURL(string: "https://sandbox-api.dexcom.com/v2/users/self/dataRange")! as URL,
                                             cachePolicy: .useProtocolCachePolicy,
                                         timeoutInterval: 10.0)
        dataRange.httpMethod = "GET"
        dataRange.allHTTPHeaderFields = headers
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://sandbox-api.dexcom.com/v2/users/self/egvs?startDate=2018-02-22T00:18:10&endDate=2018-02-23T00:18:10")! as URL,
              cachePolicy: .useProtocolCachePolicy,
          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            hasError = true
            errorMessage = error!.localizedDescription
            print(error)
          } else {
            
            let httpResponse = response as? HTTPURLResponse
            print("Status = \(httpResponse?.statusCode)")
            
            if (data != nil){
                if let decodedResponse = try? JSONDecoder().decode(DexcomData.self, from: data!) {
                    self.results = decodedResponse.evgs
                    print(results.count)
                    /*DispatchQueue.main.async {
                        // update our UI
                        self.results = decodedResponse.evgs
                        print(results.count)
                    }
                     */
                    // everything is good, so we can exit
                    //return
                }
            }

            if (data != nil){
                let responseData:String! = String(data: data!, encoding: String.Encoding.utf8)
                responseDataString = responseData ?? ""
                print(responseDataString)
                /*let sample = try decoder.decode(DexcomData.self, from: responseData)
                print(sample)*/
                }
          }
        })

        dataTask.resume()
        
        /*
        oauthswift.client.request("https://api.dexcom.com/v2/users/self/egvs?startDate=2017-06-16T15:30:00&endDate=2017-06-16T15:45:00", .GET,
              parameters: , headers: headers,
              completionHandler: { ...
        
        
                oauthswift.client.get("https://api.linkedin.com/v1/people/~") { result in
            switch result {
            case .success(let response):
                let dataString = response.string
                print(dataString)
            case .failure(let error):
                print(error)
            }
        }
        // same with request method
        oauthswift.client.request("https://api.linkedin.com/v1/people/~", .GET,
              parameters: [:], headers: [:],
              completionHandler: { ...
 */
    }
    
    /*
     func onStartUp() {
     // App launched before?
     let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
     
     let newVersion = getCurrentAppVersion()
     let newBuild = getCurrentAppBuildVersion()
     let newAppBuildString = getCurrentAppBuildVersionString()
     
     let savedVersion = settings.appVersion
     let savedBuild = settings.appBuild
     
     settings.appVersion = newVersion
     settings.appBuild = newBuild
     settings.appVersionString = newAppBuildString
     
     if launchedBefore {
     if savedVersion != newVersion || savedBuild != newBuild {
     self.update = true
     self.showSheet = true
     }
     } else {
     self.setup = true
     self.showSheet = true
     }
     
     
     // Get Images
     if settings.userImagePrivateSet == true {
     loadImageFromUserDefault(key: "userImagePrivate")
     }
     // Get Images
     if settings.userImageBusinessSet == true {
     loadImageFromUserDefault(key: "userImageBusiness")
     }
     
     WidgetManagerClass(settings: settings).updateValues()
     
     }
     */
}


public struct DexcomData: Codable {
    var unit: String
    var rateUnit: String
    var evgs: [Evgs]
}

public struct Evgs: Codable {
    var systemTime: Date
    var displayTime: Date
    var value: Int
    var realtimeValue: Int
    var smoothedValue: Int
    var status: String
    var trend: String
    var trendRate: Int
}
