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

struct DexcomData: Codable {
    var unit: String
    var rateUnit: String
    let egvs: [EgvData]
}

struct EgvData: Codable, Hashable {
    var systemTime: String
    var displayTime: String
    var value: Int
    var realtimeValue: Int?
    var smoothedValue: Int?
    var status: String?
    var trend: String?
    var trendRate: Double?
}

struct UserData {
    var time: String
    var value: Int
    var trend: String
    var trendRate: Double
}



struct EGView: View {
    
    @ObservedObject var settings: UserSettings
     
    @State var egvDATA: [EgvData]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(egvDATA, id: \.self) { item in
                    Text("Value: \(item.value)")
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .accentColor(Color.prime)
        .background(Color.prime)
        .navigationBarTitle(loc_settings, displayMode: .automatic).allowsTightening(true)
    }
}

struct ContentView: View {
    
    @ObservedObject var settings: UserSettings
    @Environment (\.presentationMode) var presentationMode
    @ObservedObject private var viewModel = SignInViewModel()
    
    let productIDs = [
        "de.nicolasott.sugaX.premium"
    ]
    
    @StateObject var storeManager = StoreManager()
    @State var navSelected: Int? = nil
   
    let oauthswift = OAuth2Swift(
        consumerKey:    "", // <= ADD
        consumerSecret: "", // <= ADD
        authorizeUrl:   "https://sandbox-api.dexcom.com/v2/oauth2/login",
        accessTokenUrl: "https://sandbox-api.dexcom.com/v2/oauth2/token",
        responseType:   "code"
    )
    
    /* PROD
    let oauthswift = OAuth2Swift(
        consumerKey:    "",
        consumerSecret: "",
        authorizeUrl:   "https://api.dexcom.com/v2/oauth2/login",
        accessTokenUrl: "https://api.dexcom.com/v2/oauth2/token",
        responseType:   "code"
    )
    */
    
    @State var hasError = false
    @State var errorMessage = ""
    @State var access_token = ""
    @State var responseDataString = ""
   
    @State var userData = [
        UserData(time: "--",
        value: 0,
        trend: "--",
        trendRate: 0.0)]
    
    @State private var dexDataEmpty = DexcomData.self
    @State private var dexdataJSON = [DexcomData]()
    @State private var dexdataRESULT = [DexcomData]()
    @State private var egvDATA = [EgvData]()
  
    
    
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
                    HStack {
                        Spacer()
                        Button(action: {
                            parseJSON2()
                        }) {
                            HStack {
                                Image(systemName: "globe").foregroundColor(Color.primeInverted)
                                Text("Parse")
                                Text("\(egvDATA.count)")
                                
                            }.padding().background(Color.white)
                        }.foregroundColor(.primeInverted)
                        
                        
                        
                        
                        Spacer()
                    }
                    VStack(alignment: .center) {
                        HStack(alignment: .bottom) {
                            Text("\(userData[userData.count-1].value)").font(.title).bold().foregroundColor(.white).padding()
                            Text("\(userData[userData.count-1].trend)").font(.headline).bold().foregroundColor(.white).padding()
                            Text("\(userData[userData.count-1].trendRate)").font(.headline).foregroundColor(.white).padding()
                           
                        }
                        Text("\(userData[userData.count-1].time)").font(.title).bold().foregroundColor(.white).padding()
                        
                    }
                  
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
                    
                    NavigationLink(destination: EGView(settings: settings, egvDATA: egvDATA).accentColor(Color.prime).edgesIgnoringSafeArea(.bottom), tag: 11, selection: $navSelected)
                    {
                        EmptyView()
                    }.isDetailLink(false)
                    
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
        viewModel.appeared()
        // IAP
        SKPaymentQueue.default().add(storeManager)
        storeManager.getProducts(productIDs: productIDs)
        //settings.purchased = true
        UserDefaults(suiteName: "group.de.nicolasott.sugaX")!.set(settings.purchased, forKey: "purchased")
    }
    
    func parseJSON() -> [EgvData]{
        let url = Bundle.main.url(forResource: "dexdata", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        
        do {
            //let responseJSON = try?JSONEncoder().encode(responseData)
            let products = try decoder.decode([DexcomData].self, from: data)
            return products[0].egvs
        } catch DecodingError.keyNotFound(let key, let context) {
            Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(let context) {
            Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
        } catch let error as NSError {
            NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
        }
        
        return [EgvData]()
    }
    
    func parseJSON2() {
        let url = Bundle.main.url(forResource: "dexdata", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()

        let dexdata = try? decoder.decode(DexcomData.self, from: data)
        //print(dexdata.egvs.count)
        egvDATA = dexdata!.egvs
        let cnt = dexdata!.egvs.count
        
        let newData = UserData(
            time: dexdata!.egvs[cnt-1].displayTime,
            value: dexdata!.egvs[cnt-1].value,
            trend: dexdata!.egvs[cnt-1].trend ?? "?",
            trendRate: dexdata!.egvs[cnt-1].trendRate ?? 0.0)
        userData.append(newData)
      
    }
    
    func oauth2Login() {
     
        // OAuthSwift
        hasError = false
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
                access_token = credential.oauthToken
                getEgvs(token: credential.oauthToken)
                
            case .failure(let error):
                hasError = true
                errorMessage = error.localizedDescription
                print(error.localizedDescription)
            }
        }
        
    }

    func getEgvs(token: String) {
        
        let headers = [
            "authorization": "Bearer \(token)"
        ]
        let dataRange =  NSMutableURLRequest(url: NSURL(string: "https://sandbox-api.dexcom.com/v2/users/self/dataRange")! as URL,
                                             cachePolicy: .useProtocolCachePolicy,
                                             timeoutInterval: 10.0)
        /* PROD
        let dataRange =  NSMutableURLRequest(url: NSURL(string: "https://api.dexcom.com/v2/users/self/dataRange")! as URL,
                                             cachePolicy: .useProtocolCachePolicy,
                                             timeoutInterval: 10.0)
        */
        
        dataRange.httpMethod = "GET"
        dataRange.allHTTPHeaderFields = headers
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://sandbox-api.dexcom.com/v2/users/self/egvs?startDate=2018-02-22T00:18:10&endDate=2018-02-23T00:18:10")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        /* PROD
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.dexcom.com/v2/users/self/egvs?startDate=2021-06-22T10:00:00&endDate=2021-06-22T10:30:00")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        */
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                hasError = true
                errorMessage = error!.localizedDescription
                //print(error!.localizedDescription)
            } else {
                
                let httpResponse = response as? HTTPURLResponse
                //print("Status = \(httpResponse?.statusCode)")
                
                if (data != nil){
                    let responseData:String! = String(data: data!, encoding: String.Encoding.utf8)
                    responseDataString = responseData ?? ""
                    print(responseDataString)
                    do {
                        //let responseJSON = try?JSONEncoder().encode(responseData)
                        let myData = try JSONDecoder().decode([DexcomData].self, from: data!)
                        self.dexdataRESULT = myData
                    } catch DecodingError.keyNotFound(let key, let context) {
                        Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                    } catch DecodingError.valueNotFound(let type, let context) {
                        Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                    } catch DecodingError.typeMismatch(let type, let context) {
                        Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                    } catch DecodingError.dataCorrupted(let context) {
                        Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                    } catch let error as NSError {
                        NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                    }
                   print("Count: \(dexdataRESULT.count)")
                }
                
                if (data != nil){
                    //let responseData:String! = String(data: data!, encoding: String.Encoding.utf8)
                    //responseDataString = responseData ?? ""
                    //print(responseDataString)
                    do {
                        //let responseJSON = try?JSONEncoder().encode(responseData)
                        let myData2 = try JSONDecoder().decode([EgvData].self, from: data!)
                        self.egvDATA = myData2
                    } catch DecodingError.keyNotFound(let key, let context) {
                        Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                    } catch DecodingError.valueNotFound(let type, let context) {
                        Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                    } catch DecodingError.typeMismatch(let type, let context) {
                        Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                    } catch DecodingError.dataCorrupted(let context) {
                        Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                    } catch let error as NSError {
                        NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                    }
                   print("Count: \(egvDATA.count)")
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



