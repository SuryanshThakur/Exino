import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var epicGamesAuth: EpicGamesAuthViewModel
    @EnvironmentObject var exinoViewModel: ExinoViewModel
    @State private var selectedGame: EpicGame? = nil
    @State private var showingFileImporter = false

    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    // Epic Games Library
                    if epicGamesAuth.isAuthenticated {
                        if !epicGamesAuth.games.isEmpty {
                            let columns = [GridItem(.adaptive(minimum: 150))]
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(epicGamesAuth.games) { game in
                                    GameItemView(game: game)
                                        .onTapGesture {
                                            self.selectedGame = game
                                        }
                                }
                            }
                            .padding()
                        }
                    }

                    // Local Games Library
                    if !exinoViewModel.installedGames.isEmpty {
                        let columns = [GridItem(.adaptive(minimum: 150))]
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(exinoViewModel.installedGames) { game in
                                LocalGameItemView(game: game)
                            }
                        }
                        .padding()
                    }

                    if !epicGamesAuth.isAuthenticated && exinoViewModel.installedGames.isEmpty {
                        Text("Connect your Epic Games account or add a local game to see your library.")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Library")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingFileImporter = true }) {
                    Label("Add Local Game", systemImage: "plus")
                }
            }
        }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.executable]) { result in
            switch result {
            case .success(let url):
                exinoViewModel.addLocalGame(from: url)
            case .failure(let error):
                print("Error importing file: \(error.localizedDescription)")
            }
        }
        .sheet(item: $selectedGame) { game in
            GameDetailView(game: game)
                .environmentObject(epicGamesAuth)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .environmentObject(EpicGamesAuthViewModel())
            .preferredColorScheme(.dark)
    }
}
