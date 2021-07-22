//
//  ContentView.swift
//  HRWatchAgent WatchKit Extension
//
//  Created by Vinoth Kumar on 20/07/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var service: LowHRMonitorService
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
            Text(service.hkStatus)
                .padding()
            Text(service.latest)
                .padding()
            Text(service.latestTimeStamp)
                .padding()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
