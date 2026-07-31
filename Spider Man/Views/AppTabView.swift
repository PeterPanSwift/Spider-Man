import SwiftUI

enum AppTab: Hashable {
    case home
    case cast
    case media
    case explore
}

struct AppTabView: View {
    let store: MovieStore
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            Tab("首頁", systemImage: "house.fill", value: AppTab.home) {
                NavigationStack {
                    HomeView(store: store)
                }
            }

            Tab("演員", systemImage: "person.3.fill", value: AppTab.cast) {
                NavigationStack {
                    CastGridView(store: store)
                }
            }

            Tab("媒體", systemImage: "play.rectangle.fill", value: AppTab.media) {
                NavigationStack {
                    MediaView(store: store)
                }
            }

            Tab("探索", systemImage: "safari.fill", value: AppTab.explore) {
                NavigationStack {
                    ExploreView(store: store)
                }
            }
        }
        .tint(SpiderTheme.signalRed)
    }
}
