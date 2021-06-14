//
//  ContentView.swift
//  sugaX
//
//  Created by Nicolas Ott on 14.06.21.
//

import SwiftUI
import StoreKit
import OAuth2

struct sugaX: View {
    
    let coloredNavAppearance = UINavigationBarAppearance()
    init() {
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = UIColor(Color.primeInverted)
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.prime)]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.prime)]
        coloredNavAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.prime)]
        
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().barTintColor = UIColor(Color.prime)
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.primeInverted)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.primeInverted)], for: .normal)
        
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = UIColor(Color.prime)
        UITableView.appearance().backgroundColor = UIColor(Color.prime)
    }
    
    @ObservedObject var settings = UserSettings()
    @Environment (\.presentationMode) var presentationMode
    
    let productIDs = [
        "de.nicolasott.sugaX.premium"
    ]
    @StateObject var storeManager = StoreManager()
    @State var navSelected: Int? = nil
    
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
                        self.oauth()
                    }) {
                        HStack {
                            Image(systemName: "lock").foregroundColor(Color.primeInverted)
                            Text("Login")
                        }
                    }.foregroundColor(.primeInverted)
                    Spacer()
                }
                
                
                Spacer()
                
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
    
    func oauth() {
        /*
         PROD
         https://api.dexcom.com/v2/oauth2/login?client_id={your_client_id}&redirect_uri={your_redirect_uri}&response_type=code&scope=offline_access&state={your_state_value}
         https://api.dexcom.com/v2/oauth2/token
         
         When targeting the sandbox environment, the base URL above should be replaced with https://sandbox-api.dexcom.com
         
         SANDBOX
         https://sandbox-api.dexcom.com/v2/oauth2/login?client_id={your_client_id}&redirect_uri={your_redirect_uri}&response_type=code&scope=offline_access&state={your_state_value}
         
         https://sandbox-api.dexcom.com/v2/oauth2/token
         */
        
        let oauth2 = OAuth2CodeGrant(settings: [
            "client_id": "ppwU1wNLpASv7Xu1aalj4S4SGnNOuRKS",
            "client_secret": "sZLbOl82PGNJZJ6i",
            "authorize_uri": "https://sandbox-api.dexcom.com/v2/oauth2/login",
            "token_uri": "https://sandbox-api.dexcom.com/v2/oauth2/token", 
            "redirect_uris": ["sugaX://oauth/callback"],   // register your own "myapp" scheme in Info.plist
            "scope": "offline_access",
            "keychain": false,         // if you DON'T want keychain integration
        ] as OAuth2JSON)
        oauth2.logger = OAuth2DebugLogger(.trace)
    
        oauth2.authorize() { authParameters, error in
            if let params = authParameters {
                print("Authorized! Access token is in `oauth2.accessToken`")
                print("Authorized! Additional parameters: \(params)")
            }
            else {
                print("Authorization was canceled or went wrong: \(error)")   // error will not be nil
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
