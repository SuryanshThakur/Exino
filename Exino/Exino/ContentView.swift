import SwiftUI

@main
struct ExinoApp: App {
    @StateObject private var viewModel = ExinoViewModel()
    @StateObject private var containerManager = ContainerManager()
    @StateObject private var epicGamesAuthViewModel = EpicGamesAuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environmentObject(containerManager)
                .environmentObject(epicGamesAuthViewModel)
                .frame(width: 800, height: 600)
                .onOpenURL { url in
                    epicGamesAuthViewModel.handleOAuthCallback(url: url)
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .appInfo) {
                Button("About Exino") {
                    // Show about window
                }
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ExinoViewModel
    @State private var showMainView = false
    
    var body: some View {
        if showMainView {
            MainDashboardView()
                .environmentObject(viewModel)
                .transition(.opacity)
        } else {
            LaunchScreenView(showMainView: $showMainView)
                .onAppear {
                    AppMover.moveToApplicationsFolderIfNeeded { success in
                        if success {
                            // Check for required dependencies on app launch
                            viewModel.checkAndInstallDependencies { _ in
                                // Dependencies check completed
                            }
                        }
                    }
                }
        }
    }
}

struct LaunchScreenView: View {
    @Binding var showMainView: Bool
    @State private var showContainerManager = false
    @EnvironmentObject var containerManager: ContainerManager
    
    var body: some View {
        ZStack {
            // Background
            Color(.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // App Icon and Title
                VStack(spacing: 20) {
                    Image(systemName: "gamecontroller.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentColor)
                    
                    Text("Exino")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    
                    Text("v1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, -10)
                }
                
                VStack(spacing: 16) {
                    // Create Container Button
                    Button(action: {
                        showContainerManager = true
                    }) {
                        Label("Create Container", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(25)
                            .shadow(radius: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Or Continue Button
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary.opacity(0.3))
                        
                        Text("or")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary.opacity(0.3))
                    }
                    .padding(.vertical, 8)
                    
                    // Continue Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMainView = true
                        }
                    }) {
                        Text("Continue to Dashboard")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .frame(width: 250, height: 50)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(25)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 10)
                
                // Footer
                VStack(spacing: 5) {
                    Text("© 2025 Exino")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        Button("Privacy Policy") {
                            // Open privacy policy
                        }
                        .buttonStyle(LinkButtonStyle())
                        
                        Button("Terms of Service") {
                            // Open terms of service
                        }
                        .buttonStyle(LinkButtonStyle())
                    }
                }
                .padding(.top, 30)
            }
            .frame(maxWidth: 500)
            .padding()
            .sheet(isPresented: $showContainerManager) {
                ContainersView()
                    .environmentObject(containerManager)
            }
        }
    }
}

struct LinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(.accentColor)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ExinoViewModel())
    }
}
