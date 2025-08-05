import SwiftUI

@main
struct ExinoApp: App {
    @StateObject private var viewModel = ExinoViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 800, minHeight: 600)
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
    
    var body: some View {
        MainDashboardView()
            .environmentObject(viewModel)
            .onAppear {
                // Check for required dependencies on app launch
                viewModel.checkAndInstallDependencies { _ in
                    // Dependencies check completed
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ExinoViewModel())
    }
}
