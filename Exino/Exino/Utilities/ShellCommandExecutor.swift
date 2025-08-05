import Foundation
import Combine
import UniformTypeIdentifiers

class ShellCommandExecutor: ObservableObject {
    // MARK: - Singleton
    static let shared = ShellCommandExecutor()
    public init() {}
    
    // MARK: - Command Execution
    
    /// Checks for required system dependencies
    /// - Parameter completion: Called with an array of missing dependencies or nil if all are present
    func checkForDependencies(completion: @escaping ([String]?) -> Void) {
        let requiredCommands = ["wine", "winetricks", "curl"]
        var missingDeps: [String] = []
        let group = DispatchGroup()
        
        for command in requiredCommands {
            group.enter()
            executeCommand("which \(command)") { _, error in
                if error != nil {
                    missingDeps.append(command)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(missingDeps.isEmpty ? nil : missingDeps)
        }
    }
    
    /// Downloads a file from a URL to a destination path
    /// - Parameters:
    ///   - url: The source URL to download from
    ///   - destination: The destination file path
    ///   - completion: Called with success/failure status
    func downloadFile(from url: URL, to destination: URL, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            do {
                // Remove existing file if it exists
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                
                // Create destination directory if needed
                let destinationDir = destination.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: destinationDir.path) {
                    try FileManager.default.createDirectory(at: destinationDir, withIntermediateDirectories: true)
                }
                
                // Move the downloaded file
                try FileManager.default.moveItem(at: tempURL, to: destination)
                DispatchQueue.main.async { completion(true) }
            } catch {
                print("Error moving downloaded file: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
        }
        task.resume()
    }
    
    /// Executes a shell command with a completion handler
    /// - Parameters:
    ///   - command: The command to execute
    ///   - completion: Called with the command output and error if any
    func executeCommand(_ command: String, completion: @escaping (String?, Error?) -> Void) {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        var outputData = Data()
        var errorData = Data()
        
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty {
                outputData.append(data)
            }
        }
        
        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty {
                errorData.append(data)
            }
        }
        
        process.terminationHandler = { process in
            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
            
            DispatchQueue.main.async {
                if process.terminationStatus != 0 {
                    let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                    let error = NSError(
                        domain: "com.exino.shell",
                        code: Int(process.terminationStatus),
                        userInfo: [NSLocalizedDescriptionKey: errorOutput]
                    )
                    completion(nil, error)
                } else {
                    let output = String(data: outputData, encoding: .utf8) ?? ""
                    completion(output, nil)
                }
            }
        }
        
        do {
            try process.run()
        } catch {
            completion(nil, error)
        }
    }
    
    /// Executes a shell command and returns the output via Combine publisher
    /// - Parameters:
    ///   - command: The command to execute
    ///   - arguments: Command line arguments
    /// - Returns: A publisher that emits output lines as they're received
    func execute(_ command: String, arguments: [String] = []) -> AnyPublisher<String, Error> {
        let process = Process()
        let pipe = Pipe()
        let outputSubject = PassthroughSubject<String, Error>()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments
        process.standardOutput = pipe
        process.standardError = pipe
        
        let outputQueue = DispatchQueue(label: "com.exino.shell-output")
        
        // Set up data handling
        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.isEmpty { return } // EOF
            
            if let output = String(data: data, encoding: .utf8) {
                outputQueue.async {
                    outputSubject.send(output)
                }
            }
        }
        
        // Handle process termination
        process.terminationHandler = { process in
            pipe.fileHandleForReading.readabilityHandler = nil
            
            if process.terminationStatus != 0 {
                let error = NSError(
                    domain: "com.exino.shell",
                    code: Int(process.terminationStatus),
                    userInfo: [NSLocalizedDescriptionKey: "Process terminated with status \(process.terminationStatus)"]
                )
                outputSubject.send(completion: .failure(error))
            } else {
                outputSubject.send(completion: .finished)
            }
        }
        
        // Start the process
        do {
            try process.run()
        } catch {
            outputSubject.send(completion: .failure(error))
        }
        
        return outputSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Dependency Checking
    
    /// Checks if a command is available in the system PATH
    /// - Parameter command: The command to check
    /// - Returns: A publisher that emits true if the command is available, false otherwise
    func checkCommandExists(_ command: String) -> AnyPublisher<Bool, Never> {
        let checkCommand = "which \(command)"
        
        return Future<Bool, Never> { promise in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/sh")
            process.arguments = ["-c", checkCommand]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                promise(.success(!output.isEmpty && output != command + " not found"))
            } catch {
                promise(.success(false))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Checks if all required dependencies are installed
    /// - Returns: A publisher that emits a tuple with the installation status of each dependency
    static func checkDependencies() -> AnyPublisher<[String: Bool], Never> {
        let executor = ShellCommandExecutor.shared
        let requiredCommands = ["brew", "wine64", "wine"]
        
        let checks = requiredCommands.map { command in
            executor.checkCommandExists(command)
                .map { (command, $0) }
        }
        
        return Publishers.MergeMany(checks)
            .collect()
            .map { results in
                Dictionary(uniqueKeysWithValues: results)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Bottle Management
    
    /// Creates a new Wine bottle at the specified path
    /// - Parameter path: Path where the bottle should be created
    /// - Returns: A publisher that emits the output of the wineboot command
    func createWineBottle(at path: String) -> AnyPublisher<String, Error> {
        let fileManager = FileManager.default
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
        
        // Set up environment for Wine
        var environment = ProcessInfo.processInfo.environment
        environment["WINEPREFIX"] = path
        
        // Create and configure the process
        let process = Process()
        process.environment = environment
        
        return execute("wineboot", arguments: ["--init"])
    }
}
