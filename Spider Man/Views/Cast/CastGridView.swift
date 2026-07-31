import SwiftUI

struct CastGridView: View {
    let store: MovieStore
    private let columns = [
        GridItem(.adaptive(minimum: 154), spacing: 14)
    ]

    var body: some View {
        ZStack {
            SpiderBackground()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(store.movie.sortedCast) { member in
                        NavigationLink(
                            destination: CastDetailView(member: member)
                        ) {
                            CastGridCard(member: member)
                        }
                        .buttonStyle(.plain)
                        .cinematicScrollReveal()
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("演員陣容")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct CastGridCard: View {
    let member: CastMember

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RemoteArtwork(
                url: TMDBImageURL.make(path: member.profilePath, size: .profile),
                cornerRadius: 22,
                fallbackSymbol: "person.crop.circle.fill"
            )
            .frame(height: 210)
            Text(member.name)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(member.character)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .frame(minHeight: 32, alignment: .topLeading)
        }
        .padding(10)
        .background(SpiderTheme.card, in: RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.08))
        }
    }
}
