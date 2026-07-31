import Foundation

struct PersonDetails: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let biography: String
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let knownForDepartment: String
    let profilePath: String?
    let homepage: String?
    let alsoKnownAs: [String]
    let gender: Int
    let popularity: Double
    let combinedCredits: PersonCombinedCredits?
    let images: PersonImagesResponse?
    let externalIDs: PersonExternalIDs?

    enum CodingKeys: String, CodingKey {
        case id, name, biography, birthday, deathday, homepage, gender, popularity, images
        case placeOfBirth = "place_of_birth"
        case knownForDepartment = "known_for_department"
        case profilePath = "profile_path"
        case alsoKnownAs = "also_known_as"
        case combinedCredits = "combined_credits"
        case externalIDs = "external_ids"
    }

    func mergingEnglishFallback(_ english: PersonDetails) -> PersonDetails {
        PersonDetails(
            id: id,
            name: name.isEmpty ? english.name : name,
            biography: biography.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? english.biography
                : biography,
            birthday: birthday ?? english.birthday,
            deathday: deathday ?? english.deathday,
            placeOfBirth: placeOfBirth ?? english.placeOfBirth,
            knownForDepartment: knownForDepartment.isEmpty
                ? english.knownForDepartment
                : knownForDepartment,
            profilePath: profilePath ?? english.profilePath,
            homepage: homepage ?? english.homepage,
            alsoKnownAs: alsoKnownAs.isEmpty ? english.alsoKnownAs : alsoKnownAs,
            gender: gender,
            popularity: popularity,
            combinedCredits: combinedCredits ?? english.combinedCredits,
            images: images ?? english.images,
            externalIDs: externalIDs ?? english.externalIDs
        )
    }
}

struct PersonCombinedCredits: Codable, Equatable {
    let cast: [PersonCredit]
    let crew: [PersonCredit]
}

struct PersonCredit: Codable, Equatable, Identifiable {
    let tmdbID: Int
    let creditID: String?
    let title: String?
    let name: String?
    let originalTitle: String?
    let originalName: String?
    let mediaType: String
    let character: String?
    let job: String?
    let posterPath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let voteAverage: Double?
    let popularity: Double?

    var id: String {
        creditID ?? "\(mediaType)-\(tmdbID)"
    }

    var displayTitle: String {
        title ?? name ?? originalTitle ?? originalName ?? "未命名作品"
    }

    var displayYear: String {
        let date = releaseDate ?? firstAirDate ?? ""
        return String(date.prefix(4))
    }

    var mediaLabel: String {
        mediaType == "tv" ? "影集" : "電影"
    }

    enum CodingKeys: String, CodingKey {
        case title, name, character, job, popularity
        case tmdbID = "id"
        case creditID = "credit_id"
        case originalTitle = "original_title"
        case originalName = "original_name"
        case mediaType = "media_type"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
    }
}

struct PersonImagesResponse: Codable, Equatable {
    let profiles: [MovieImage]
}

struct PersonExternalIDs: Codable, Equatable {
    let imdbID: String?
    let facebookID: String?
    let instagramID: String?
    let tiktokID: String?
    let twitterID: String?
    let wikidataID: String?
    let youtubeID: String?

    enum CodingKeys: String, CodingKey {
        case imdbID = "imdb_id"
        case facebookID = "facebook_id"
        case instagramID = "instagram_id"
        case tiktokID = "tiktok_id"
        case twitterID = "twitter_id"
        case wikidataID = "wikidata_id"
        case youtubeID = "youtube_id"
    }

    var hasAnyLink: Bool {
        imdbID != nil ||
        facebookID != nil ||
        instagramID != nil ||
        tiktokID != nil ||
        twitterID != nil ||
        youtubeID != nil
    }
}
