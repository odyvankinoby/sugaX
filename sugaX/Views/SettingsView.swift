//
//  SettingsView.swift
//  sugaX
//
//  Created by Nicolas Ott on 14.06.21.
//
import SwiftUI
import Combine


            


struct SettingsView: View {
    
    @ObservedObject var settings: UserSettings
    @StateObject var storeManager: StoreManager
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
              
                    
                }
        }
        .edgesIgnoringSafeArea(.bottom)
        .accentColor(Color.prime)
        .background(Color.prime)
        .navigationBarTitle(loc_settings, displayMode: .automatic).allowsTightening(true)
    }
}
            
