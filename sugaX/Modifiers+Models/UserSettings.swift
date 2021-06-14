//
//  UserSettings.swift
//  sugaX
//
//  Created by Nicolas Ott on 14.06.21.
//

import Foundation
import SwiftUI
import Combine

class UserSettings: ObservableObject {
    
    // IAP
    @Published var purchased: Bool { didSet { UserDefaults.standard.set(purchased, forKey: "de.nicolasott.sugaX.premium") } }
    @Published var launchedBefore: Bool {
             didSet {
                 UserDefaults.standard.set(launchedBefore, forKey: "launchedBefore") } }

    // APP VERSION
    @Published var appVersion: String { didSet { UserDefaults.standard.set(appVersion, forKey: "appVersion") } }
    @Published var appBuild: String { didSet { UserDefaults.standard.set(appBuild, forKey: "appBuild") } }
    @Published var appVersionString: String { didSet { UserDefaults.standard.set(appVersionString, forKey: "appVersionString") } }

    init() {
        self.purchased = UserDefaults.standard.object(forKey: "de.nicolasott.sugaX.premium") as? Bool ?? false
        self.launchedBefore = UserDefaults.standard.object(forKey: "launchedBefore") as? Bool ?? false
        
        self.appVersion = UserDefaults.standard.object(forKey: "appVersion") as? String ?? ""
        self.appBuild = UserDefaults.standard.object(forKey: "appBuild") as? String ?? ""
        self.appVersionString = UserDefaults.standard.object(forKey: "appVersionString") as? String ?? ""
    }
}

