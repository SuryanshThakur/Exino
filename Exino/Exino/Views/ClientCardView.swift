import SwiftUI

struct ClientCardView: View {
    @Binding var client: GameClient
    var onInstall: () -> Void
    var onRun: () -> Void
    var onUninstall: () -> Void
    
    private var iconName: String {
        switch client.name.lowercased() {
        case "steam": return "steam"
        case "epic games": return "e.square.fill"
        case "gog galaxy": return "g.square.fill"
        default: return "gamecontroller"
        }
    }
    
    private var iconColor: Color {
        switch client.name.lowercased() {
        case "steam": return .blue
        case "epic games": return .purple
        case "gog galaxy": return .indigo
        default: return .accentColor
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(client.name)
                        .font(.headline)
                    
                    Text(client.status.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
                
                Spacer()
                
                if client.status == .notInstalled {
                    Button(action: onInstall) {
                        Label("Install", systemImage: "arrow.down.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                } else {
                    HStack(spacing: 8) {
                        Button(action: onRun) {
                            Label("Run", systemImage: "play.circle")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button(role: .destructive, action: onUninstall) {
                            Label("Uninstall", systemImage: "trash")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
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
    }
    
    private var statusColor: Color {
        switch client.status {
        case .installed: return .green
        case .notInstalled: return .secondary
        case .installing: return .orange
        case .error: return .red
        }
    }
}

// MARK: - Previews

struct ClientCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ClientCardView(
                client: .constant(GameClient(name: "Steam", status: .notInstalled)),
                onInstall: {},
                onRun: {},
                onUninstall: {}
            )
            .previewDisplayName("Not Installed")
            
            ClientCardView(
                client: .constant(GameClient(name: "Epic Games", status: .installed)),
                onInstall: {},
                onRun: {},
                onUninstall: {}
            )
            .previewDisplayName("Installed")
        }
        .padding()
        .frame(width: 400)
        .preferredColorScheme(.dark)
    }
}
