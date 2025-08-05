import Foundation
import Combine
import SwiftUI

class ExinoViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var gameClients: [GameClient] = GameClient.sampleClients
    @Published var installedGames: [Game] = []
    @Published var consoleOutput: [ConsoleMessage] = []
    @Published var isRunningCommand = false
    
    // Console View Model
    let consoleViewModel = ConsoleViewModel()
    
    // MARK: - Private Properties
    
    private let shell = ShellCommandExecutor()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        loadInstalledGames()
        
        // Sync console output with console view model
        $consoleOutput
            .receive(on: RunLoop.main)
            .sink { [weak self] messages in
                self?.consoleViewModel.messages = messages
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    // MARK: - Game Client Handlers
    
    func handleInstallClient(_ client: GameClient) {
        log("Installing \(client.name)...", type: .info)
        
        // Update the client status to installing
        if let index = gameClients.firstIndex(where: { $0.id == client.id }) {
            gameClients[index].status = .installing
            
            // Simulate installation process
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                self.gameClients[index].status = .installed
                self.gameClients[index].installPath = "/Applications/\(client.name).app"
                self.log("\(client.name) installed successfully", type: .success)
            }
        }
    }
    
    func handleRun(_ client: GameClient) {
        log("Launching \(client.name)...", type: .info)
        
        // Implementation for running the client
        // This is a placeholder - actual implementation would launch the client app
        log("\(client.name) launched successfully", type: .success)
    }
    
    func handleUninstall(_ client: GameClient) {
        log("Uninstalling \(client.name)...", type: .info)
        
        // Update the client status
        if let index = gameClients.firstIndex(where: { $0.id == client.id }) {
            gameClients[index].status = .notInstalled
            gameClients[index].installPath = nil
            log("\(client.name) uninstalled successfully", type: .success)
        }
    }
    
    // MARK: - Game Handlers
    
    func handleRun(_ game: Game) {
        runGame(game)
    }
    
    func handleUninstall(_ game: Game) {
        log("Uninstalling \(game.name)...", type: .info)
        
        // Remove the game from installed games
        if let index = installedGames.firstIndex(where: { $0.id == game.id }) {
            installedGames.remove(at: index)
            log("\(game.name) uninstalled successfully", type: .success)
        }
    }
    
    func runGame(_ game: Game) {
        log("Preparing to launch \(game.name)...", type: .info)
        isRunningCommand = true
        
        // First check dependencies
        checkAndInstallDependencies { [weak self] dependenciesInstalled in
            guard let self = self else { return }
            
            guard dependenciesInstalled else {
                self.log("Please install the required dependencies first.", type: .error)
                self.isRunningCommand = false
                return
            }
            
            // Then setup wine prefix if needed
            self.setupWinePrefix { [weak self] prefixReady in
                guard let self = self else { return }
                
                guard prefixReady else {
                    self.log("Failed to setup Wine prefix.", type: .error)
                    self.isRunningCommand = false
                    return
                }
                
                // Now run the game
                self.executeGame(game)
            }
        }
    }
    
    // MARK: - Private Methods
    
    func log(_ message: String, type: ConsoleMessage.MessageType) {
        let consoleMessage = ConsoleMessage(text: message, type: type)
        DispatchQueue.main.async {
            self.consoleOutput.append(consoleMessage)
        }
    }
    
    private func loadInstalledGames() {
        // Load installed games from UserDefaults or any other storage
        // This is a placeholder implementation
        installedGames = []
    }
    
    func checkAndInstallDependencies(completion: @escaping (Bool) -> Void) {
        log("Checking for required dependencies...", type: .info)
        
        // Standard paths for Wine and Winetricks
        let winePath = "/opt/homebrew/bin/wine"
        let winetricksPath = "/opt/homebrew/bin/winetricks"
        
        // Check if Wine is installed
        guard FileManager.default.fileExists(atPath: winePath) else {
            log("Wine is not installed. Please install it with: brew install --cask wine-stable", type: .error)
            completion(false)
            return
        }
        
        // Check if Winetricks is installed
        guard FileManager.default.fileExists(atPath: winetricksPath) else {
            log("Winetricks is not installed. Please install it with: brew install winetricks", type: .error)
            completion(false)
            return
        }
        
        log("All dependencies are installed.", type: .success)
        completion(true)
    }
    
    private func setupWinePrefix(completion: @escaping (Bool) -> Void) {
        let winePrefix = "\(FileManager.default.homeDirectoryForCurrentUser.path)/.wine-gtasa"
        let winePath = "/opt/homebrew/bin/wine"
        let winebootPath = "/opt/homebrew/bin/wineboot"
        let winetricksPath = "/opt/homebrew/bin/winetricks"
        
        // Set up environment variables
        let envVars = [
            "WINEPREFIX='\(winePrefix)'",
            "WINEARCH=win64",
            "WINEDEBUG=-all",
            "DISPLAY=:0"
        ].joined(separator: " ")
        
        // Create Wine prefix directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: winePrefix) {
            do {
                try fileManager.createDirectory(atPath: winePrefix, withIntermediateDirectories: true, attributes: nil)
                log("Created Wine prefix at \(winePrefix)", type: .info)
                
                // Initialize Wine prefix
                let initCommand = "\(envVars) \(winebootPath) --init"
                log("Initializing Wine prefix...", type: .info)
                
                shell.executeCommand(initCommand) { [weak self] output, error in
                    if let error = error {
                        self?.log("Failed to initialize Wine prefix: \(error.localizedDescription)", type: .error)
                        completion(false)
                        return
                    }
                    
                    // Install required components using winetricks
                    let winetricksCommand = "\(envVars) \(winetricksPath) -q d3dx9_43 d3dcompiler_43 vcrun2008 xinput"
                    self?.log("Installing required Windows components...", type: .info)
                    
                    self?.shell.executeCommand(winetricksCommand) { output, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                self?.log("Error installing components: \(error.localizedDescription)", type: .error)
                                completion(false)
                            } else {
                                self?.log("Wine prefix setup completed successfully", type: .success)
                                completion(true)
                            }
                        }
                    }
                }
            } catch {
                log("Failed to create Wine prefix: \(error.localizedDescription)", type: .error)
                completion(false)
            }
        } else {
            log("Using existing Wine prefix at \(winePrefix)", type: .info)
            completion(true)
        }
    }
    
    private func executeGame(_ game: Game) {
        if game.executablePath.lowercased().hasSuffix(".exe") {
            // Run with Wine
            let winePrefix = "\(FileManager.default.homeDirectoryForCurrentUser.path)/.wine-gtasa"
            let winePath = "/opt/homebrew/bin/wine"
            
            let envVars = [
                "WINEPREFIX='\(winePrefix)'",
                "WINEARCH=win64",
                "WINEDEBUG=-all",
                "DISPLAY=:0",
                "PATH=\(ProcessInfo.processInfo.environment["PATH"] ?? ""):/opt/homebrew/bin"
            ].joined(separator: " ")
            
            let command = "\(envVars) '\(winePath)' '\(game.executablePath)' -windowed"
            log("Launching \(game.name) with Wine...", type: .info)
            log("Command: \(command)", type: .command)
            
            shell.executeCommand(command) { [weak self] output, error in
                DispatchQueue.main.async {
                    self?.isRunningCommand = false
                    if let error = error {
                        self?.log("Error launching game: \(error.localizedDescription)", type: .error)
                    } else {
                        self?.log("\(game.name) has exited.", type: .info)
                    }
                }
            }
        } else {
            // Run natively
            log("Launching \(game.name) natively...", type: .info)
            
            let process = Process()
            process.launchPath = "/usr/bin/open"
            process.arguments = ["-a", game.executablePath]
            
            process.terminationHandler = { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isRunningCommand = false
                    self?.log("\(game.name) has exited.", type: .info)
                }
            }
            
            do {
                try process.run()
                log("Launched \(game.name) with PID: \(process.processIdentifier)", type: .info)
            } catch {
                self.isRunningCommand = false
                self.log("Failed to launch \(game.name): \(error.localizedDescription)", type: .error)
            }
        }
    }
}
