//
//  WidgetManagerClass.swift
//  sugaX
//
//  Created by Nicolas Ott on 14.06.21.
//

import SwiftUI
import WidgetKit

class WidgetManagerClass {
    
    @ObservedObject var settings: UserSettings
    
    init(settings: UserSettings) {
        self.settings = settings
    }
    
    func updateValues() {
        
        UserDefaults(suiteName: "group.de.nicolasott.sugaX")!.set(settings.purchased, forKey: "purchased")

        WidgetCenter.shared.reloadAllTimelines()
    }
}


