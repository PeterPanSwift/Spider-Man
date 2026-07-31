import SwiftUI

struct BackdropGalleryView: View {
    let backdrops: [MovieImage]

    private let columns = [
        GridItem(.adaptive(minimum: 300), spacing: 16)
    ]

    var body: some View {
        ZStack {
            SpiderBackground()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(backdrops) { backdrop in
                        NavigationLink(
                            destination: BackdropDetailView(backdrop: backdrop)
                        ) {
                            BackdropGridCard(backdrop: backdrop)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("全部劇照")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(backdrops.count) 張")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct BackdropGridCard: View {
    let backdrop: MovieImage

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RemoteArtwork(
                url: TMDBImageURL.make(
                    path: backdrop.filePath,
                    size: .backdropThumbnail
                ),
                cornerRadius: 22,
                fallbackSymbol: "photo.fill"
            )
            .aspectRatio(displayAspectRatio, contentMode: .fit)

            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(9)
                .background(.ultraThinMaterial, in: Circle())
                .padding(10)
        }
        .contentShape(RoundedRectangle(cornerRadius: 22))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("電影劇照")
        .accessibilityHint("點兩下查看大圖")
    }

    private var displayAspectRatio: Double {
        backdrop.aspectRatio > 0 ? backdrop.aspectRatio : 16.0 / 9.0
    }
}

struct BackdropDetailView: View {
    let backdrop: MovieImage

    var body: some View {
        ZStack {
            SpiderBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    RemoteArtwork(
                        url: TMDBImageURL.make(
                            path: backdrop.filePath,
                            size: .original
                        ),
                        cornerRadius: 20,
                        fallbackSymbol: "photo.fill"
                    )
                    .aspectRatio(displayAspectRatio, contentMode: .fit)
                    .frame(maxWidth: .infinity)

                    BackdropMetadataCard(
                        width: backdrop.width,
                        height: backdrop.height,
                        voteAverage: backdrop.voteAverage
                    )
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("劇照預覽")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var displayAspectRatio: Double {
        backdrop.aspectRatio > 0 ? backdrop.aspectRatio : 16.0 / 9.0
    }
}

struct BackdropMetadataCard: View {
    let width: Int
    let height: Int
    let voteAverage: Double

    var body: some View {
        GlassCard {
            HStack(spacing: 22) {
                Label("\(width) × \(height)", systemImage: "aspectratio")
                if voteAverage > 0 {
                    Label(
                        voteAverage.formatted(
                            .number.precision(.fractionLength(1))
                        ),
                        systemImage: "star.fill"
                    )
                    .foregroundStyle(.yellow)
                }
            }
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
