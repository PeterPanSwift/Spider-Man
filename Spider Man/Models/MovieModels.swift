import Foundation

struct Genre: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
}

struct CastMember: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let originalName: String?
    let character: String
    let profilePath: String?
    let order: Int

    enum CodingKeys: String, CodingKey {
        case id, name, character, order
        case originalName = "original_name"
        case profilePath = "profile_path"
    }
}

struct CrewMember: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let job: String
}

struct CreditsResponse: Codable, Equatable {
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct MovieImage: Codable, Equatable, Identifiable {
    let filePath: String
    let aspectRatio: Double
    let width: Int
    let height: Int
    let voteAverage: Double

    var id: String { filePath }

    enum CodingKeys: String, CodingKey {
        case width, height
        case filePath = "file_path"
        case aspectRatio = "aspect_ratio"
        case voteAverage = "vote_average"
    }
}

struct ImageResponse: Codable, Equatable {
    let backdrops: [MovieImage]
    let posters: [MovieImage]
    let logos: [MovieImage]
}

struct TMDBVideo: Codable, Equatable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    let official: Bool

    var webURL: URL? {
        guard site.caseInsensitiveCompare("YouTube") == .orderedSame else {
            return nil
        }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }

    var thumbnailURL: URL? {
        guard site.caseInsensitiveCompare("YouTube") == .orderedSame else {
            return nil
        }
        return URL(string: "https://i.ytimg.com/vi/\(key)/hqdefault.jpg")
    }
}

struct VideoResponse: Codable, Equatable {
    let results: [TMDBVideo]
}

struct SimilarMovie: Codable, Equatable, Identifiable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
}

struct SimilarMovieResponse: Codable, Equatable {
    let results: [SimilarMovie]
}

struct MovieDetails: Codable, Equatable, Identifiable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let tagline: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let runtime: Int?
    let voteAverage: Double
    let voteCount: Int
    let status: String
    let genres: [Genre]
    let credits: CreditsResponse?
    let images: ImageResponse?
    let videos: VideoResponse?
    let similar: SimilarMovieResponse?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, tagline, runtime, status, genres, credits, images, videos, similar
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

struct MovieFact: Identifiable, Equatable {
    let id: String
    let symbol: String
    let title: String
    let value: String
    let detail: String
}

extension MovieDetails {
    static let fallback = MovieDetails(
        id: 969681,
        title: "蜘蛛人：重生日",
        originalTitle: "Spider-Man: Brand New Day",
        overview: "在一個不再記得彼得・帕克的世界裡，他全心投入打擊犯罪。當舊友繼續向前、城市出現無法看見的新威脅，壓力也在他身上引發一場難以控制的轉變。",
        tagline: "世界或許忘了彼得・帕克，但他沒有忘記他們。",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2026-07-31",
        runtime: nil,
        voteAverage: 0,
        voteCount: 0,
        status: "Planned",
        genres: [
            Genre(id: 28, name: "動作"),
            Genre(id: 12, name: "冒險"),
            Genre(id: 878, name: "科幻")
        ],
        credits: CreditsResponse(
            cast: [
                CastMember(id: 1136406, name: "Tom Holland", originalName: "Tom Holland", character: "Peter Parker / Spider-Man", profilePath: nil, order: 0),
                CastMember(id: 505710, name: "Zendaya", originalName: "Zendaya", character: "MJ", profilePath: nil, order: 1),
                CastMember(id: 1190668, name: "Sadie Sink", originalName: "Sadie Sink", character: "角色未公開", profilePath: nil, order: 2),
                CastMember(id: 1133349, name: "Jacob Batalon", originalName: "Jacob Batalon", character: "Ned Leeds", profilePath: nil, order: 3),
                CastMember(id: 19182, name: "Jon Bernthal", originalName: "Jon Bernthal", character: "Frank Castle / Punisher", profilePath: nil, order: 4),
                CastMember(id: 103, name: "Mark Ruffalo", originalName: "Mark Ruffalo", character: "Bruce Banner / Hulk", profilePath: nil, order: 5),
                CastMember(id: 1345419, name: "Michael Mando", originalName: "Michael Mando", character: "Mac Gargan / Scorpion", profilePath: nil, order: 6),
                CastMember(id: 168082, name: "Tramell Tillman", originalName: "Tramell Tillman", character: "Bill Metzger", profilePath: nil, order: 7)
            ],
            crew: [
                CrewMember(id: 1272770, name: "Destin Daniel Cretton", job: "Director"),
                CrewMember(id: 15344, name: "Chris McKenna", job: "Writer"),
                CrewMember(id: 15345, name: "Erik Sommers", job: "Writer")
            ]
        ),
        images: nil,
        videos: nil,
        similar: nil
    )

    var directorName: String {
        credits?.crew.first(where: { $0.job == "Director" })?.name ?? "Destin Daniel Cretton"
    }

    var sortedCast: [CastMember] {
        (credits?.cast ?? []).sorted { $0.order < $1.order }
    }

    var facts: [MovieFact] {
        [
            MovieFact(
                id: "release",
                symbol: "calendar",
                title: "上映日期",
                value: releaseDate.isEmpty ? "2026-07-31" : releaseDate,
                detail: "Sony Pictures 官方頁面列出的美國院線上映日為 2026 年 7 月 31 日；各地上映日期可能不同。"
            ),
            MovieFact(
                id: "director",
                symbol: "movieclapper",
                title: "導演",
                value: directorName,
                detail: "Destin Daniel Cretton 曾執導《尚氣與十環傳奇》，這次接手 MCU 蜘蛛人的全新篇章。"
            ),
            MovieFact(
                id: "genre",
                symbol: "sparkles",
                title: "類型",
                value: genres.map(\.name).joined(separator: "・"),
                detail: "TMDb 將本片歸類為科幻、動作與冒險電影。"
            ),
            MovieFact(
                id: "runtime",
                symbol: "clock",
                title: "片長",
                value: runtime.map { "\($0) 分鐘" } ?? "尚未公布",
                detail: "此欄位直接讀取 TMDb；資料庫尚未提供時，App 會明確顯示尚未公布。"
            ),
            MovieFact(
                id: "status",
                symbol: "checkmark.seal",
                title: "TMDb 狀態",
                value: status,
                detail: "這是 TMDb 電影詳情 API 回傳的製作／上映狀態。"
            )
        ]
    }

    func mergingFallback(_ fallback: MovieDetails = .fallback) -> MovieDetails {
        MovieDetails(
            id: id,
            title: title.isEmpty ? fallback.title : title,
            originalTitle: originalTitle.isEmpty ? fallback.originalTitle : originalTitle,
            overview: overview.isEmpty ? fallback.overview : overview,
            tagline: tagline.isEmpty ? fallback.tagline : tagline,
            posterPath: posterPath ?? fallback.posterPath,
            backdropPath: backdropPath ?? fallback.backdropPath,
            releaseDate: releaseDate.isEmpty ? fallback.releaseDate : releaseDate,
            runtime: runtime ?? fallback.runtime,
            voteAverage: voteAverage,
            voteCount: voteCount,
            status: status.isEmpty ? fallback.status : status,
            genres: genres.isEmpty ? fallback.genres : genres,
            credits: mergeCredits(fallback: fallback),
            images: images ?? fallback.images,
            videos: videos ?? fallback.videos,
            similar: similar ?? fallback.similar
        )
    }

    private func mergeCredits(fallback: MovieDetails) -> CreditsResponse? {
        let liveCredits = credits
        let fallbackCredits = fallback.credits
        let cast = mergeCast(live: liveCredits?.cast ?? [], fallback: fallbackCredits?.cast ?? [])
        let crew = liveCredits?.crew.isEmpty == false ? liveCredits?.crew ?? [] : fallbackCredits?.crew ?? []
        return CreditsResponse(cast: cast, crew: crew)
    }

    private func mergeCast(live: [CastMember], fallback: [CastMember]) -> [CastMember] {
        var knownIDs = Set(live.map(\.id))
        var knownNames = Set(
            live.flatMap { member in
                [member.name, member.originalName].compactMap { $0?.lowercased() }
            }
        )
        var result = live
        for member in fallback
        where !knownIDs.contains(member.id) &&
        !knownNames.contains(member.name.lowercased()) {
            result.append(member)
            knownIDs.insert(member.id)
            knownNames.insert(member.name.lowercased())
        }
        return result.sorted { $0.order < $1.order }
    }
}

enum TMDBImageSize: String {
    case poster = "w500"
    case profile = "w342"
    case backdropThumbnail = "w780"
    case backdrop = "w1280"
    case original
}

enum TMDBImageURL {
    static func make(path: String?, size: TMDBImageSize) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)\(path)")
    }
}
