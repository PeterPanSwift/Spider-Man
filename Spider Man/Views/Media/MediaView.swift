import SwiftUI

struct MediaView: View {
    let store: MovieStore

    var body: some View {
        ZStack {
            SpiderBackground()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 28) {
                    TMDBVideosSection(videos: store.movie.videos?.results ?? [])
                    GalleryPager(
                        images: galleryImages,
                        backdrops: backdrops
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("媒體中心")
        .navigationBarTitleDisplayMode(.large)
    }

    private var galleryImages: [MovieImage] {
        let posters = store.movie.images?.posters ?? []
        return Array((backdrops + posters).prefix(8))
    }

    private var backdrops: [MovieImage] {
        store.movie.images?.backdrops ?? []
    }
}

struct GalleryPager: View {
    let images: [MovieImage]
    let backdrops: [MovieImage]
    @State private var selectedPage = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom, spacing: 12) {
                SectionTitle("劇照情報", eyebrow: "TMDB GALLERY")
                if !backdrops.isEmpty {
                    NavigationLink(
                        destination: BackdropGalleryView(backdrops: backdrops)
                    ) {
                        Label("全部 \(backdrops.count) 張", systemImage: "square.grid.2x2")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(SpiderTheme.signalRed.gradient, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            TabView(selection: $selectedPage) {
                if images.isEmpty {
                    Tab(value: 0) {
                        GalleryFallbackPage(index: 0)
                    }
                    Tab(value: 1) {
                        GalleryFallbackPage(index: 1)
                    }
                    Tab(value: 2) {
                        GalleryFallbackPage(index: 2)
                    }
                } else {
                    ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                        Tab(value: index) {
                            RemoteArtwork(
                                url: TMDBImageURL.make(path: image.filePath, size: .backdrop),
                                cornerRadius: 24
                            )
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 260)
            .accessibilityLabel("TMDb 電影劇照，可左右滑動")
        }
    }
}

struct GalleryFallbackPage: View {
    let index: Int

    var body: some View {
        ZStack {
            ArtworkPlaceholder(symbol: index == 1 ? "web" : "spider.fill")
            VStack(spacing: 8) {
                Text(["NEW MASK", "NEW CITY", "NEW DAY"][index])
                    .font(.title.weight(.black))
                    .tracking(2)
                Text("設定 TMDb Token 後顯示官方資料庫劇照")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct TMDBVideosSection: View {
    let videos: [TMDBVideo]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("正式預告", eyebrow: "TMDB VIDEOS")
            if availableVideos.isEmpty {
                GlassCard {
                    Label(
                        "TMDb 目前尚未提供橫式正式預告；仍可在官方網站查看最新消息。",
                        systemImage: "film.stack"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            } else {
                ForEach(availableVideos) { video in
                    if let url = video.webURL {
                        NavigationLink(
                            destination: TrailerWebView(title: video.name, url: url)
                        ) {
                            VideoLinkRow(video: video)
                        }
                        .buttonStyle(.plain)
                        .cinematicScrollReveal()
                    }
                }
            }
        }
    }

    private var availableVideos: [TMDBVideo] {
        Array(
            videos
                .filter {
                    $0.webURL != nil
                        && $0.type.caseInsensitiveCompare("Trailer") == .orderedSame
                }
                .prefix(6)
        )
    }
}

struct VideoLinkRow: View {
    let video: TMDBVideo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            YouTubeThumbnail(video: video)

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(video.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text("\(video.site)・\(video.type)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.up.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .background(SpiderTheme.card)
        .clipShape(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(video.name)，YouTube \(video.type)")
    }
}

struct YouTubeThumbnail: View {
    let video: TMDBVideo

    var body: some View {
        GeometryReader { geometry in
            RemoteArtwork(
                url: video.thumbnailURL,
                cornerRadius: 0,
                fallbackSymbol: "photo.fill"
            )
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipped()
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .accessibilityHidden(true)
    }
}
