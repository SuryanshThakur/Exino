import SwiftUI

// MARK: - Game Clients Section View
private struct GameClientsSection: View {
    @Binding var clients: [GameClient]
    let onInstall: (GameClient) -> Void
    let onRun: (GameClient) -> Void
    let onUninstall: (GameClient) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GAME CLIENTS")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ForEach($clients) { $client in
                ClientCardView(
                    client: $client,
                    onInstall: { onInstall(client) },
                    onRun: { onRun(client) },
                    onUninstall: { onUninstall(client) }
                )
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Installed Games Section View
private struct InstalledGamesSection: View {
    @Binding var games: [Game]
    let onRun: (Game) -> Void
    let onUninstall: (Game) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INSTALLED GAMES")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if games.isEmpty {
                Text("No games installed. Click the + button to add a game.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach($games) { $game in
                    GameCardView(
                        game: $game,
                        onRun: { onRun(game) },
                        onUninstall: { onUninstall(game) }
                    )
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Console View Wrapper
private struct ConsoleViewWrapper: View {
    @ObservedObject var viewModel: ConsoleViewModel
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack {
            Spacer()
            if isVisible {
                ConsoleView(viewModel: viewModel)
                    .frame(height: 200)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

// MARK: - Main Dashboard View
struct MainDashboardView: View {
    @EnvironmentObject var viewModel: ExinoViewModel
    @State private var isShowingAddGameView = false
    @State private var isShowingConsole = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Game Clients Section
                        GameClientsSection(
                            clients: $viewModel.gameClients,
                            onInstall: { client in
                                if let index = viewModel.gameClients.firstIndex(where: { $0.id == client.id }) {
                                    viewModel.handleInstallClient(viewModel.gameClients[index])
                                }
                            },
                            onRun: { client in
                                if let index = viewModel.gameClients.firstIndex(where: { $0.id == client.id }) {
                                    viewModel.handleRun(viewModel.gameClients[index])
                                }
                            },
                            onUninstall: { client in
                                if let index = viewModel.gameClients.firstIndex(where: { $0.id == client.id }) {
                                    viewModel.handleUninstall(viewModel.gameClients[index])
                                }
                            }
                        )
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Installed Games Section
                        InstalledGamesSection(
                            games: $viewModel.installedGames,
                            onRun: { game in
                                if let index = viewModel.installedGames.firstIndex(where: { $0.id == game.id }) {
                                    viewModel.handleRun(viewModel.installedGames[index])
                                }
                            },
                            onUninstall: { game in
                                if let index = viewModel.installedGames.firstIndex(where: { $0.id == game.id }) {
                                    viewModel.handleUninstall(viewModel.installedGames[index])
                                }
                            }
                        )
                    }
                    .padding(.bottom, isShowingConsole ? 220 : 20)
                }
                
                // Console View (positioned at the bottom)
                ConsoleViewWrapper(
                    viewModel: viewModel.consoleViewModel,
                    isVisible: $isShowingConsole
                )
            }
            .navigationTitle("Exino")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isShowingAddGameView = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .status) {
                    Button(action: { withAnimation { isShowingConsole.toggle() } }) {
                        Image(systemName: "terminal")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddGameView) {
                AddGameView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            viewModel.checkAndInstallDependencies { _ in }
        }
    }
}

// MARK: - Preview
struct MainDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ExinoViewModel()
        viewModel.installedGames = Game.sampleGames
        viewModel.gameClients = GameClient.sampleClients
        return MainDashboardView()
            .environmentObject(viewModel)
            .preferredColorScheme(.dark)
    }
}
