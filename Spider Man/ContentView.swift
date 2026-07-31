import SwiftUI

struct ContentView: View {
    @State private var store = MovieStore()

    var body: some View {
        AppTabView(store: store)
            .task {
                await store.loadIfNeeded()
            }
            .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
