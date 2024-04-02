//
//  MainView.swift
//  Photo Squarer
//
//  Created by Dillan Wrye on 7/16/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tag(0)
                .tabItem {
                    Label("Image", systemImage: "photo")
                }
            
            VideoView()
                .tag(1)
                .tabItem {
                    Label("Video", systemImage: "video")
                }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

