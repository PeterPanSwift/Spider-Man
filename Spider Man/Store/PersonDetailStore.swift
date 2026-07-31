import Foundation
import Observation

@Observable
final class PersonDetailStore {
    enum Phase: Equatable {
        case idle
        case loading
        case ready
        case failed(String)
    }

    private(set) var phase: Phase = .idle
    private(set) var person: PersonDetails?
    private(set) var featuredCredits: [PersonCredit] = []
    private(set) var profileImages: [MovieImage] = []

    private let client: TMDBClient
    private var loadedPersonID: Int?

    init(client: TMDBClient = TMDBClient()) {
        self.client = client
    }

    func load(personID: Int) async {
        guard loadedPersonID != personID else { return }
        loadedPersonID = personID
        phase = .loading

        do {
            let localized = try await client.fetchPerson(
                id: personID,
                language: "zh-TW"
            )
            let details = await addEnglishFallbackIfNeeded(
                to: localized,
                personID: personID
            )
            guard !Task.isCancelled else { return }

            person = details
            featuredCredits = Self.prepareFeaturedCredits(
                details.combinedCredits?.cast ?? []
            )
            profileImages = Array(
                (details.images?.profiles ?? [])
                    .sorted { $0.voteAverage > $1.voteAverage }
                    .prefix(16)
            )
            phase = .ready
        } catch is CancellationError {
            return
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func retry(personID: Int) async {
        loadedPersonID = nil
        await load(personID: personID)
    }

    private func addEnglishFallbackIfNeeded(
        to localized: PersonDetails,
        personID: Int
    ) async -> PersonDetails {
        guard localized.biography
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty else {
            return localized
        }

        guard let english = try? await client.fetchPerson(
            id: personID,
            language: "en-US"
        ) else {
            return localized
        }
        return localized.mergingEnglishFallback(english)
    }

    private static func prepareFeaturedCredits(
        _ credits: [PersonCredit]
    ) -> [PersonCredit] {
        let sorted = credits.sorted {
            ($0.popularity ?? 0, $0.voteAverage ?? 0) >
            ($1.popularity ?? 0, $1.voteAverage ?? 0)
        }
        var seen = Set<String>()
        return Array(
            sorted
                .filter { credit in
                    guard credit.posterPath != nil else { return false }
                    let mediaID = "\(credit.mediaType)-\(credit.tmdbID)"
                    return seen.insert(mediaID).inserted
                }
                .prefix(16)
        )
    }
}
