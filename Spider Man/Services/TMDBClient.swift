import Foundation

enum TMDBError: LocalizedError {
    case missingToken
    case invalidResponse
    case server(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .missingToken:
            "尚未設定 TMDb Read Access Token"
        case .invalidResponse:
            "TMDb 回傳了無法辨識的資料"
        case .server(let statusCode):
            "TMDb 服務回應錯誤（HTTP \(statusCode)）"
        }
    }
}

struct TMDBClient {
    static let movieID = 969681

    private let session: URLSession
    private let token: String?

    init(session: URLSession = .shared, token: String? = TMDBConfiguration.readAccessToken) {
        self.session = session
        self.token = token
    }

    func fetchMovie() async throws -> MovieDetails {
        try await request(
            path: "movie/\(Self.movieID)",
            queryItems: [
            URLQueryItem(name: "language", value: "zh-TW"),
            URLQueryItem(name: "append_to_response", value: "credits,images,videos,similar"),
            URLQueryItem(name: "include_image_language", value: "zh,en,null"),
            URLQueryItem(name: "include_video_language", value: "zh,en")
            ]
        )
    }

    func fetchPerson(id: Int, language: String) async throws -> PersonDetails {
        try await request(
            path: "person/\(id)",
            queryItems: [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(
                    name: "append_to_response",
                    value: "combined_credits,images,external_ids"
                )
            ]
        )
    }

    private func request<Response: Decodable>(
        path: String,
        queryItems: [URLQueryItem]
    ) async throws -> Response {
        guard let token, !token.isEmpty else {
            throw TMDBError.missingToken
        }

        var components = URLComponents(
            string: "https://api.themoviedb.org/3/\(path)"
        )
        components?.queryItems = queryItems
        guard let url = components?.url else {
            throw TMDBError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw TMDBError.server(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}

enum TMDBConfiguration {
    static var readAccessToken: String? {
        let environmentToken = ProcessInfo.processInfo.environment["TMDB_READ_ACCESS_TOKEN"]
        let infoToken = Bundle.main.object(
            forInfoDictionaryKey: "TMDBReadAccessToken"
        ) as? String
        return [environmentToken, infoToken]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { token in
                !token.isEmpty &&
                !token.hasPrefix("$(") &&
                token != "PASTE_YOUR_TOKEN_HERE"
            }
    }
}
