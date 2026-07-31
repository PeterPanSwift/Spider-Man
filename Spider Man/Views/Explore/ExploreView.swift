import SwiftUI

struct ExploreView: View {
    let store: MovieStore

    var body: some View {
        List {
            MovieFactsListSection(facts: store.movie.facts)
            OfficialLinksSection()
            SimilarMoviesListSection(movies: store.movie.similar?.results ?? [])
            DataCreditsSection(isLiveData: store.isLiveData)
        }
        .scrollContentBackground(.hidden)
        .background {
            SpiderBackground()
        }
        .navigationTitle("探索情報")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MovieFactsListSection: View {
    let facts: [MovieFact]

    var body: some View {
        Section("電影檔案") {
            ForEach(facts) { fact in
                NavigationLink(
                    destination: MovieFactDetailView(fact: fact)
                ) {
                    MovieFactRow(fact: fact)
                }
                .listRowBackground(SpiderTheme.card)
            }
        }
    }
}

struct MovieFactRow: View {
    let fact: MovieFact

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: fact.symbol)
                .frame(width: 34, height: 34)
                .foregroundStyle(SpiderTheme.signalRed)
                .background(SpiderTheme.signalRed.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(fact.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(fact.value)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 5)
    }
}

struct MovieFactDetailView: View {
    let fact: MovieFact

    var body: some View {
        ZStack {
            SpiderBackground()
            VStack(spacing: 24) {
                Image(systemName: fact.symbol)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(SpiderTheme.signalRed)
                    .frame(width: 104, height: 104)
                    .background(SpiderTheme.signalRed.opacity(0.13), in: Circle())
                VStack(spacing: 8) {
                    Text(fact.title)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(fact.value)
                        .font(.largeTitle.weight(.black))
                        .multilineTextAlignment(.center)
                }
                GlassCard {
                    Text(fact.detail)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.78))
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle(fact.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OfficialLinksSection: View {
    var body: some View {
        Section("官方連結") {
            NavigationLink(
                destination: OfficialWebView()
            ) {
                Label("Sony Pictures 官方網站", systemImage: "safari.fill")
                    .foregroundStyle(.white)
                    .padding(.vertical, 5)
            }
            .listRowBackground(SpiderTheme.card)

            NavigationLink(
                destination: TMDBWebView()
            ) {
                Label("在 TMDb 查看電影", systemImage: "film.fill")
                    .foregroundStyle(.white)
                    .padding(.vertical, 5)
            }
            .listRowBackground(SpiderTheme.card)
        }
    }
}

struct SimilarMoviesListSection: View {
    let movies: [SimilarMovie]

    var body: some View {
        if !movies.isEmpty {
            Section("你可能也喜歡") {
                ForEach(movies.prefix(8)) { movie in
                    NavigationLink(
                        destination: SimilarMovieDetailView(movie: movie)
                    ) {
                        SimilarMovieRow(movie: movie)
                    }
                    .listRowBackground(SpiderTheme.card)
                }
            }
        }
    }
}

struct SimilarMovieRow: View {
    let movie: SimilarMovie

    var body: some View {
        HStack(spacing: 12) {
            RemoteArtwork(
                url: TMDBImageURL.make(path: movie.posterPath, size: .poster),
                cornerRadius: 9,
                fallbackSymbol: "film.fill"
            )
            .frame(width: 48, height: 68)
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(movie.releaseDate.isEmpty ? "上映日未定" : movie.releaseDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}

struct SimilarMovieDetailView: View {
    let movie: SimilarMovie

    var body: some View {
        ZStack {
            SpiderBackground()
            VStack(spacing: 20) {
                RemoteArtwork(
                    url: TMDBImageURL.make(path: movie.posterPath, size: .poster),
                    cornerRadius: 26,
                    fallbackSymbol: "film.fill"
                )
                .frame(width: 230, height: 340)
                Text(movie.title)
                    .font(.title.weight(.black))
                    .multilineTextAlignment(.center)
                Label(
                    movie.releaseDate.isEmpty ? "上映日未定" : movie.releaseDate,
                    systemImage: "calendar"
                )
                if movie.voteAverage > 0 {
                    Label(
                        movie.voteAverage.formatted(.number.precision(.fractionLength(1))),
                        systemImage: "star.fill"
                    )
                    .foregroundStyle(.yellow)
                }
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("相關電影")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataCreditsSection: View {
    let isLiveData: Bool

    var body: some View {
        Section("資料來源") {
            VStack(alignment: .leading, spacing: 8) {
                Label(
                    isLiveData ? "已連線 TMDb API" : "等待 TMDb Token",
                    systemImage: isLiveData ? "checkmark.icloud.fill" : "key.fill"
                )
                .font(.headline)
                Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 5)
            .listRowBackground(SpiderTheme.card)
        }
    }
}

struct TMDBWebView: View {
    private let url = URL(
        string: "https://www.themoviedb.org/movie/969681-spider-man-brand-new-day?language=zh-TW"
    )!

    var body: some View {
        WebView(url: url)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("TMDb")
            .navigationBarTitleDisplayMode(.inline)
    }
}
