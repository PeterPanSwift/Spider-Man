import Foundation
import Observation

@Observable
final class MovieStore {
    enum Phase: Equatable {
        case idle
        case loading
        case ready
        case failed(String)
    }

    private(set) var movie: MovieDetails = .fallback
    private(set) var phase: Phase = .idle
    private(set) var isLiveData = false

    private let client: TMDBClient
    private var hasLoaded = false

    init(client: TMDBClient = TMDBClient()) {
        self.client = client
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await refresh()
    }

    func refresh() async {
        phase = .loading
        do {
            movie = try await client.fetchMovie().mergingFallback()
            isLiveData = true
            phase = .ready
        } catch is CancellationError {
            return
        } catch {
            movie = .fallback
            isLiveData = false
            phase = .failed(error.localizedDescription)
        }
    }
}
