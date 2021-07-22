//
//  HRWatchAgentApp.swift
//  HRWatchAgent WatchKit Extension
//
//  Created by Vinoth Kumar on 20/07/21.
//

import SwiftUI

@main
struct HRWatchAgentApp: App {
    
    let service = LowHRMonitorService()
    
    init(){
      
        service.start()
    }
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environmentObject(service)
            }
        }
    }
}
