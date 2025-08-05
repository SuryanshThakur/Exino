import SwiftUI
import UniformTypeIdentifiers

struct AddGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: ExinoViewModel
    
    @State private var gameName = ""
    @State private var executablePath = ""
    @State private var showFilePicker = false
    @State private var validationError: String? = nil
    
    private var isFormValid: Bool {
        !gameName.trimmingCharacters(in: .whitespaces).isEmpty && 
        !executablePath.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Game")
                .font(.title2)
                .padding(.top)
            
            Form {
                TextField("Game Name", text: $gameName)
                    .onChange(of: gameName) { _,_ in validateForm() }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Executable:")
                            .frame(width: 100, alignment: .leading)
                        
                        Text(executablePath.isEmpty ? "No file selected" : URL(fileURLWithPath: executablePath).lastPathComponent)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundColor(executablePath.isEmpty ? .secondary : .primary)
                        
                        Button("Browse...") {
                            showFilePicker = true
                        }
                    }
                    
                    if let error = validationError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .transition(.opacity)
                    }
                }
                .padding(.vertical, 8)
                .fileImporter(
                    isPresented: $showFilePicker,
                    allowedContentTypes: [.exe, .unixExecutable, .data],
                    allowsMultipleSelection: false
                ) { result in
                    handleFileSelection(result)
                }
            }
            .frame(width: 450, height: 150)
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Add Game") {
                    addGame()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isFormValid || validationError != nil)
            }
            .padding()
        }
        .padding()
        .frame(width: 500)
    }
    
    private func validateForm() {
        guard !executablePath.isEmpty else {
            validationError = nil
            return
        }
        
        let fileManager = FileManager.default
        let fileURL = URL(fileURLWithPath: executablePath)
        
        // Check if file exists
        guard fileManager.fileExists(atPath: executablePath) else {
            validationError = "File does not exist"
            return
        }
        
        // Check if it's an executable (either .exe or has executable permissions)
        let isExe = fileURL.pathExtension.lowercased() == "exe"
        let isExecutable = fileManager.isExecutableFile(atPath: executablePath)
        
        if !isExe && !isExecutable {
            validationError = "Selected file is not an executable (.exe)"
            return
        }
        
        // Check if the game already exists
        if viewModel.installedGames.contains(where: { $0.executablePath == executablePath }) {
            validationError = "This game is already added"
            return
        }
        
        validationError = nil
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                // Resolve symlinks and standardize the path
                let resolvedURL = url.resolvingSymlinksInPath().standardized
                executablePath = resolvedURL.path
                validateForm()
                
                // Auto-fill game name if empty
                if gameName.isEmpty {
                    gameName = resolvedURL.deletingPathExtension().lastPathComponent
                }
            }
        case .failure(let error):
            viewModel.log("Error selecting file: \(error.localizedDescription)", type: .error)
        }
    }
    
    private func addGame() {
        guard isFormValid, validationError == nil else { return }
        
        let game = Game(
            name: gameName.trimmingCharacters(in: .whitespacesAndNewlines),
            executablePath: executablePath
        )
        
        viewModel.installedGames.append(game)
        viewModel.log("Added game: \(game.name)", type: .success)
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - File Type Extensions

extension UTType {
    static let exe = UTType(filenameExtension: "exe")!
    static let lnk = UTType(filenameExtension: "lnk")!
    static let url = UTType.url
}

// MARK: - Previews

struct AddGameView_Previews: PreviewProvider {
    static var previews: some View {
        AddGameView()
            .environmentObject(ExinoViewModel())
            .preferredColorScheme(.dark)
    }
}
