import SwiftUI

struct GameDetailView: View {
    @EnvironmentObject var epicGamesAuth: EpicGamesAuthViewModel
    let game: EpicGame

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let coverURL = game.keyImages?.first(where: { $0.type == "DieselGameBox" })?.url, let url = URL(string: coverURL) {
                    AsyncImage(url: url) {
                        $0.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .aspectRatio(3/4, contentMode: .fit)
                            .cornerRadius(12)
                        Image(systemName: "gamecontroller.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                }

                Text(game.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let description = game.description {
                    Text(description)
                        .font(.body)
                } else {
                    Text("No description available.")
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(game.name)
        .onAppear {
            // Fetch details only if they haven't been fetched already
            if game.description == nil {
                epicGamesAuth.fetchGameDetails(for: game)
            }
        }
    }
}
