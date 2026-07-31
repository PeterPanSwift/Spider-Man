import SwiftUI

struct CastDetailView: View {
    let member: CastMember
    @State private var store = PersonDetailStore()

    var body: some View {
        ZStack {
            SpiderBackground()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 28) {
                    PersonHeroSection(
                        name: store.person?.name ?? member.name,
                        character: member.character,
                        profilePath: store.person?.profilePath ?? member.profilePath
                    )

                    switch store.phase {
                    case .idle, .loading:
                        PersonLoadingSection()
                    case .ready:
                        if let person = store.person {
                            PersonFactsSection(
                                department: person.knownForDepartment,
                                birthday: person.birthday,
                                placeOfBirth: person.placeOfBirth,
                                creditCount: person.combinedCredits?.cast.count ?? 0
                            )
                            PersonBiographySection(biography: person.biography)
                            if !person.alsoKnownAs.isEmpty {
                                PersonAliasesSection(aliases: person.alsoKnownAs)
                            }
                            if !store.featuredCredits.isEmpty {
                                PersonKnownWorksSection(
                                    credits: store.featuredCredits
                                )
                            }
                            if !store.profileImages.isEmpty {
                                PersonPhotosSection(images: store.profileImages)
                            }
                            if let externalIDs = person.externalIDs,
                               externalIDs.hasAnyLink {
                                PersonExternalLinksSection(
                                    externalIDs: externalIDs
                                )
                            }
                        }
                    case .failed(let message):
                        PersonErrorSection(
                            message: message,
                            retry: {
                                Task {
                                    await store.retry(personID: member.id)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(store.person?.name ?? member.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: member.id) {
            await store.load(personID: member.id)
        }
    }
}

struct PersonHeroSection: View {
    let name: String
    let character: String
    let profilePath: String?

    var body: some View {
        VStack(spacing: 18) {
            RemoteArtwork(
                url: TMDBImageURL.make(path: profilePath, size: .profile),
                cornerRadius: 30,
                fallbackSymbol: "person.crop.circle.fill"
            )
            .frame(maxWidth: 320)
            .frame(height: 410)
            .clipShape(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
            )

            VStack(spacing: 7) {
                Text(name)
                    .font(.largeTitle.weight(.black))
                    .multilineTextAlignment(.center)
                Text(character)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(SpiderTheme.signalRed)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
    }
}

struct PersonLoadingSection: View {
    var body: some View {
        GlassCard {
            HStack(spacing: 14) {
                ProgressView()
                    .tint(SpiderTheme.signalRed)
                VStack(alignment: .leading, spacing: 4) {
                    Text("正在載入人物檔案")
                        .font(.headline)
                    Text("同步簡介、代表作品、照片與社群資料…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PersonErrorSection: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("人物資料載入失敗", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("重新載入", action: retry)
                    .buttonStyle(.borderedProminent)
                    .tint(SpiderTheme.signalRed)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PersonFactsSection: View {
    let department: String
    let birthday: String?
    let placeOfBirth: String?
    let creditCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("人物情報", eyebrow: "PROFILE")
            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    PersonFactCard(
                        symbol: "theatermasks.fill",
                        label: "主要職業",
                        value: department.isEmpty ? "尚未提供" : department
                    )
                    PersonFactCard(
                        symbol: "birthday.cake.fill",
                        label: "生日",
                        value: birthday ?? "尚未提供"
                    )
                    PersonFactCard(
                        symbol: "mappin.and.ellipse",
                        label: "出生地",
                        value: placeOfBirth ?? "尚未提供"
                    )
                    PersonFactCard(
                        symbol: "film.stack.fill",
                        label: "演出紀錄",
                        value: "\(creditCount) 部"
                    )
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct PersonFactCard: View {
    let symbol: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(SpiderTheme.signalRed)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.bold))
                .lineLimit(3)
        }
        .frame(width: 150, height: 120, alignment: .topLeading)
        .padding(16)
        .background(SpiderTheme.card, in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.08))
        }
    }
}

struct PersonBiographySection: View {
    let biography: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("人物簡介", eyebrow: "BIOGRAPHY")
            GlassCard {
                Text(
                    biography.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? "TMDb 目前尚未提供這位演員的個人簡介。"
                        : biography
                )
                .font(.body)
                .foregroundStyle(.white.opacity(0.78))
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct PersonAliasesSection: View {
    let aliases: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("其他姓名", eyebrow: "ALSO KNOWN AS")
            Text(aliases.formatted())
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SpiderTheme.card, in: RoundedRectangle(cornerRadius: 22))
        }
    }
}

struct PersonKnownWorksSection: View {
    let credits: [PersonCredit]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("代表作品", eyebrow: "KNOWN FOR")
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 14) {
                    ForEach(credits) { credit in
                        PersonCreditCard(credit: credit)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct PersonCreditCard: View {
    let credit: PersonCredit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                RemoteArtwork(
                    url: TMDBImageURL.make(
                        path: credit.posterPath,
                        size: .poster
                    ),
                    cornerRadius: 18,
                    fallbackSymbol: "film.fill"
                )
                .frame(width: 142, height: 205)

                Text(credit.mediaLabel)
                    .font(.caption2.weight(.black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(8)
            }
            Text(credit.displayTitle)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(2)
            HStack(spacing: 6) {
                if !credit.displayYear.isEmpty {
                    Text(credit.displayYear)
                }
                if let vote = credit.voteAverage, vote > 0 {
                    Label(
                        vote.formatted(.number.precision(.fractionLength(1))),
                        systemImage: "star.fill"
                    )
                    .foregroundStyle(.yellow)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(width: 142, alignment: .leading)
    }
}

struct PersonPhotosSection: View {
    let images: [MovieImage]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("更多照片", eyebrow: "PORTRAITS")
            ScrollView(.horizontal) {
                LazyHStack(spacing: 14) {
                    ForEach(images) { image in
                        RemoteArtwork(
                            url: TMDBImageURL.make(
                                path: image.filePath,
                                size: .profile
                            ),
                            cornerRadius: 20,
                            fallbackSymbol: "person.crop.circle.fill"
                        )
                        .frame(width: 170, height: 238)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct PersonExternalLinksSection: View {
    let externalIDs: PersonExternalIDs

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("外部連結", eyebrow: "FOLLOW")
            HStack(spacing: 10) {
                if let imdbID = externalIDs.imdbID,
                   let url = URL(string: "https://www.imdb.com/name/\(imdbID)") {
                    PersonExternalLink(title: "IMDb", symbol: "film", url: url)
                }
                if let instagramID = externalIDs.instagramID,
                   let url = URL(string: "https://www.instagram.com/\(instagramID)") {
                    PersonExternalLink(title: "Instagram", symbol: "camera", url: url)
                }
                if let twitterID = externalIDs.twitterID,
                   let url = URL(string: "https://x.com/\(twitterID)") {
                    PersonExternalLink(title: "X", symbol: "bubble.left", url: url)
                }
            }
        }
    }
}

struct PersonExternalLink: View {
    let title: String
    let symbol: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(SpiderTheme.card, in: Capsule())
        }
    }
}
