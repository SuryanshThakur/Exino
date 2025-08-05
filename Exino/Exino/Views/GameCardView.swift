import SwiftUI

struct GameCardView: View {
    @Binding var game: Game
    var onRun: () -> Void
    var onUninstall: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Game icon with fallback to system image
                if let icon = game.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "gamecontroller.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .frame(width: 40, height: 40)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(game.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if let client = game.client {
                        Text(client.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: onRun) {
                        Label(
                            game.isRunning ? "Running" : "Run",
                            systemImage: game.isRunning ? "stop.circle" : "play.circle"
                        )
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(game.isRunning ? .green : .blue)
                    
                    Button(role: .destructive, action: onUninstall) {
                        Label("Uninstall", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
        .opacity(game.isRunning ? 0.8 : 1.0)
        .animation(.easeInOut, value: game.isRunning)
    }
}

// MARK: - Extensions

extension Game {
    var icon: NSImage? {
        // In a real app, you might load this from the game's directory
        // or from a cache of downloaded icons
        return nil
    }
}

// MARK: - Previews

struct GameCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameCardView(
                game: .constant(Game(name: "Sample Game", executablePath: "/path/to/game.exe")),
                onRun: {},
                onUninstall: {}
            )
            .previewDisplayName("Not Running")
            
            GameCardView(
                game: .constant({
                    var game = Game(name: "Running Game", executablePath: "/path/to/game.exe")
                    game.isRunning = true
                    return game
                }()),
                onRun: {},
                onUninstall: {}
            )
            .previewDisplayName("Running")
        }
        .padding()
        .frame(width: 400)
        .preferredColorScheme(.dark)
    }
}
