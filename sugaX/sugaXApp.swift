//
//  sugaXApp.swift
//  sugaX
//
//  Created by Nicolas Ott on 14.06.21.
//
/*
import SwiftUI

@main
struct sugaXApp: App {
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
    
    var body: some Scene {
        WindowGroup {
            ContentView(settings: settings).accentColor(Color.prime).edgesIgnoringSafeArea(.bottom)
        }
    }
}
 */
