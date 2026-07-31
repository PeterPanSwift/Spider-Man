import SwiftUI

struct HomeView: View {
    let store: MovieStore

    var body: some View {
        ZStack {
            SpiderBackground()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 28) {
                    HeroPager(movie: store.movie)
                    DataSourceBanner(
                        phase: store.phase,
                        isLiveData: store.isLiveData,
                        refresh: store.refresh
                    )
                    MovieOverviewSection(
                        tagline: store.movie.tagline,
                        overview: store.movie.overview
                    )
                    .cinematicScrollReveal()
                    QuickFactsSection(movie: store.movie)
                        .cinematicScrollReveal()
                    CastRailSection(cast: Array(store.movie.sortedCast.prefix(10)))
                        .cinematicScrollReveal()
                    WebSignalCard()
                        .cinematicScrollReveal()
                }
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                await store.refresh()
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

struct HeroPager: View {
    let movie: MovieDetails
    @State private var selectedPage = 0

    private var artworkURLs: [URL?] {
        let backdrop = TMDBImageURL.make(path: movie.backdropPath, size: .backdrop)
        let gallery = movie.images?.backdrops.prefix(4).map {
            TMDBImageURL.make(path: $0.filePath, size: .backdrop)
        } ?? []
        let urls = [backdrop] + gallery
        return urls.compactMap { $0 }.isEmpty ? [nil, nil, nil] : urls
    }

    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach(Array(artworkURLs.enumerated()), id: \.offset) { index, url in
                Tab(value: index) {
                    HeroPage(
                        imageURL: url,
                        movieTitle: movie.title,
                        originalTitle: movie.originalTitle,
                        releaseDate: movie.releaseDate,
                        genres: movie.genres.map(\.name)
                    )
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 560)
        .accessibilityLabel("電影主視覺，可左右滑動")
    }
}

struct HeroPage: View {
    let imageURL: URL?
    let movieTitle: String
    let originalTitle: String
    let releaseDate: String
    let genres: [String]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRevealed = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteArtwork(url: imageURL, cornerRadius: 0)
                .frame(maxWidth: .infinity)
                .frame(height: 560)
            LinearGradient(
                colors: [.clear, SpiderTheme.midnight.opacity(0.55), SpiderTheme.midnight],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack(alignment: .leading, spacing: 12) {
                Text("A BRAND NEW DAY")
                    .font(.caption.weight(.black))
                    .tracking(3)
                    .foregroundStyle(SpiderTheme.signalRed)
                Text(movieTitle)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.72)
                Text(originalTitle)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
                HStack(spacing: 8) {
                    CapsuleTag(text: releaseDate)
                    ForEach(genres.prefix(2), id: \.self) { genre in
                        CapsuleTag(text: genre)
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 52)
            .opacity(reduceMotion || isRevealed ? 1 : 0)
            .offset(y: reduceMotion || isRevealed ? 0 : 26)
        }
        .onAppear {
            guard !reduceMotion else {
                isRevealed = true
                return
            }
            withAnimation(
                .spring(response: 0.7, dampingFraction: 0.78)
                    .delay(0.12)
            ) {
                isRevealed = true
            }
        }
    }
}

struct DataSourceBanner: View {
    let phase: MovieStore.Phase
    let isLiveData: Bool
    let refresh: () async -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isLiveData ? Color.green.opacity(0.18) : Color.orange.opacity(0.18))
                Image(systemName: isLiveData ? "checkmark.icloud.fill" : "bolt.horizontal.icloud.fill")
                    .foregroundStyle(isLiveData ? .green : .orange)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(isLiveData ? "TMDb 即時資料" : "展示資料模式")
                    .font(.subheadline.weight(.bold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            if phase != .loading {
                Button {
                    Task { await refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .accessibilityLabel("重新整理 TMDb 資料")
            } else {
                ProgressView()
            }
        }
        .padding(.horizontal, 22)
    }

    private var message: String {
        switch phase {
        case .idle:
            "準備連線"
        case .loading:
            "正在同步電影、卡司、圖片與影片資料…"
        case .ready:
            "電影 ID 969681"
        case .failed(let message):
            message
        }
    }
}

struct MovieOverviewSection: View {
    let tagline: String
    let overview: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("新的面具，新的開始", eyebrow: "STORY")
            GlassCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("“\(tagline)”")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, SpiderTheme.signalRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text(overview)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.76))
                        .lineSpacing(5)
                }
            }
        }
        .padding(.horizontal, 22)
    }
}

struct QuickFactsSection: View {
    let movie: MovieDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("一眼掌握", eyebrow: "INTEL")
            HStack(spacing: 10) {
                QuickFactCard(symbol: "movieclapper.fill", value: movie.directorName, label: "導演")
                QuickFactCard(
                    symbol: "clock.fill",
                    value: movie.runtime.map { "\($0) 分" } ?? "待公布",
                    label: "片長"
                )
                QuickFactCard(
                    symbol: "star.fill",
                    value: movie.voteCount > 0 ? movie.voteAverage.formatted(.number.precision(.fractionLength(1))) : "NEW",
                    label: "TMDb"
                )
            }
        }
        .padding(.horizontal, 22)
    }
}

struct QuickFactCard: View {
    let symbol: String
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(SpiderTheme.signalRed)
            Text(value)
                .font(.subheadline.weight(.bold))
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .padding(14)
        .background(SpiderTheme.card, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct CastRailSection: View {
    let cast: [CastMember]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("城市裡的面孔", eyebrow: "CAST")
                .padding(.horizontal, 22)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 14) {
                    ForEach(cast) { member in
                        NavigationLink(
                            destination: CastDetailView(member: member)
                        ) {
                            CastRailCard(member: member)
                        }
                        .buttonStyle(.plain)
                        .cinematicScrollReveal(axis: .horizontal)
                    }
                }
                .padding(.horizontal, 22)
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct CastRailCard: View {
    let member: CastMember

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RemoteArtwork(
                url: TMDBImageURL.make(path: member.profilePath, size: .profile),
                cornerRadius: 20,
                fallbackSymbol: "person.crop.circle.fill"
            )
            .frame(width: 138, height: 174)
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            Text(member.name)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(member.character)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 138, alignment: .leading)
    }
}

struct WebSignalCard: View {
    var body: some View {
        NavigationLink(
            destination: OfficialWebView()
        ) {
            HStack(spacing: 16) {
                Image(systemName: "safari.fill")
                    .font(.title2)
                    .foregroundStyle(SpiderTheme.electricBlue)
                VStack(alignment: .leading, spacing: 3) {
                    Text("進入官方情報網")
                        .font(.headline)
                    Text("在 App 內開啟 Sony Pictures 官方網站")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(SpiderTheme.card, in: RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 22)
    }
}
