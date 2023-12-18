

import SwiftUI


@main
struct MovieLookupApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    DiscoverView()
                }
               .tabItem {
                  Image(systemName: "magnifyingglass")
               Text("Discover")
           }
                
                
            }
        }
    }}

