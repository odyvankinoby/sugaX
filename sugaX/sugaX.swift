//
//  sugaXApp.swift
//  sugaX
//
//  Created by Nicolas Ott on 14.06.21.
//

import SwiftUI
import OAuthSwift

@main
struct sugaX: App {
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
    
    /*
        "client_id": "ppwU1wNLpASv7Xu1aalj4S4SGnNOuRKS",
        "client_secret": "sZLbOl82PGNJZJ6i",
        "authorize_uri": "https://sandbox-api.dexcom.com/v2/oauth2/login",
        "token_uri": "https://sandbox-api.dexcom.com/v2/oauth2/token",
        "redirect_uris": ["sugaX://oauth/callback"],   // register your own "myapp" scheme in Info.plist
        "scope": "offline_access",
        "keychain": false,         // if you DON'T want keychain integration
     "https://sandbox-api.dexcom.com/v2/users/self/devices?startDate=2017-06-16T08:00:00&endDate=2017-06-17T08:00:00"
    */
    
    
    @ObservedObject var settings = UserSettings()

    var body: some Scene {
        WindowGroup {
            ContentView(settings: settings)
                .accentColor(Color.prime)
                .edgesIgnoringSafeArea(.bottom)
                .onOpenURL(perform: { url in
                    print("Callback url: \(url)")
                    if url.host == "callback" {
                        print("Handing Callback to OAuthSwift: \(String(describing: url.host))")
                        OAuthSwift.handle(url: url)
                    }
                })
                
        }
    }
}

