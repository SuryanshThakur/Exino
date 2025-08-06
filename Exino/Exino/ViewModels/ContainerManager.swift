import Foundation
import Combine

class ContainerManager: ObservableObject {
    @Published var containers: [Container] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let fileManager = FileManager.default
    private let shell = ShellCommandExecutor.shared
    
    init() {
        loadContainers()
    }
    
    func createContainer(name: String, wineVersion: String, completion: @escaping (Result<Container, Error>) -> Void) {
        let container = Container(
            name: name,
            path: "\(Container.defaultContainersPath)/\(name)",
            wineVersion: wineVersion,
            createdAt: Date()
        )
        
        // Create container directory if it doesn't exist
        do {
            try fileManager.createDirectory(atPath: container.path, withIntermediateDirectories: true)
            
            // Set up environment for Wine
            let envVars = [
                "WINEPREFIX='\(container.path)'",
                "WINEARCH=win64",
                "WINEDEBUG=-all"
            ].joined(separator: " ")
            
            // Initialize Wine prefix
            let command = "\(envVars) wineboot --init"
            
            shell.executeCommand(command) { [weak self] output, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.error = "Failed to create container: \(error.localizedDescription)"
                        completion(.failure(error))
                        return
                    }
                    
                    self?.containers.append(container)
                    self?.saveContainers()
                    completion(.success(container))
                }
            }
            
        } catch {
            self.error = "Failed to create container directory: \(error.localizedDescription)"
            completion(.failure(error))
        }
    }
    
    func deleteContainer(_ container: Container) {
        do {
            try fileManager.removeItem(atPath: container.path)
            containers.removeAll { $0.id == container.id }
            saveContainers()
        } catch {
            self.error = "Failed to delete container: \(error.localizedDescription)"
        }
    }
    
    func setDefaultContainer(_ container: Container) {
        containers.indices.forEach { index in
            containers[index].isDefault = (containers[index].id == container.id)
        }
        saveContainers()
    }
    
    private func loadContainers() {
        do {
            let containersPath = Container.defaultContainersPath
            let containerURLs = try fileManager.contentsOfDirectory(
                at: URL(fileURLWithPath: containersPath),
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            
            self.containers = containerURLs.compactMap { url in
                let name = url.lastPathComponent
                let wineVersion = "6.0" // Default version, could be read from container config
                return Container(
                    name: name,
                    path: url.path,
                    wineVersion: wineVersion,
                    createdAt: (try? fileManager.attributesOfItem(atPath: url.path)[.creationDate] as? Date) ?? Date(),
                    isDefault: false
                )
            }
            
        } catch {
            // If directory doesn't exist yet, create it
            if (error as NSError).code == NSFileNoSuchFileError {
                try? fileManager.createDirectory(
                    atPath: Container.defaultContainersPath,
                    withIntermediateDirectories: true
                )
                self.containers = []
            } else {
                self.error = "Failed to load containers: \(error.localizedDescription)"
            }
        }
    }
    
    private func saveContainers() {
        // In a real app, you might want to save container metadata to a file
        // For now, we're just keeping them in memory
    }
}
