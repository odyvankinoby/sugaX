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
    
    @State var hasError = false
    @State var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    //Spacer()
                    Text("Welcome SugaX Pal!").font(.title).foregroundColor(.primeInverted)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button(action: {
                       
                       
                                   
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
                        self.navSelected = 2
                    }) {
                        HStack {
                            
                            Image(systemName: "lock").foregroundColor(Color.primeInverted)
                            Text("Device")
                           
                        }.padding().background(Color.white)
                    }.foregroundColor(.primeInverted)
                    Spacer()
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
              // Do your request
            
            case .failure(let error):
                hasError = true
                errorMessage = error.localizedDescription
                print(error.localizedDescription)
            }
        }
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
