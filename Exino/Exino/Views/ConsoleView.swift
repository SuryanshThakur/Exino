import SwiftUI

struct ConsoleView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ConsoleViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title, clear button, and close button
            HStack {
                Text("Console")
                    .font(.headline)
                
                Spacer()
                
                // Clear button
                Button(action: { viewModel.clear() }) {
                    Label("Clear", systemImage: "trash")
                        .labelStyle(.iconOnly)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Clear console")
                .padding(.trailing, 8)
                
                // Close button
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .overlay(Divider(), alignment: .bottom)
            
            // Console output
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.offset) { index, message in
                            Text(message.timestamp.formatted(date: .omitted, time: .standard) + " - " + message.text)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(message.type.color)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.vertical, 2)
                                .id(index)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onChange(of: viewModel.messages) { oldValue, newValue in
                    if let lastIndex = newValue.indices.last, lastIndex >= 0 {
                        withAnimation {
                            scrollView.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Progress and status
            VStack(spacing: 8) {
                if viewModel.isRunning {
                    ProgressView()
                        .scaleEffect(0.5, anchor: .center)
                        .frame(height: 20)
                }
                
                if !viewModel.statusMessage.isEmpty {
                    Text(viewModel.statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        }
        .frame(minWidth: 600, minHeight: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - View Model

class ConsoleViewModel: ObservableObject {
    @Published var messages: [ConsoleMessage] = [] {
        didSet {
            // Ensure we don't exceed memory limits
            let maxMessages = 1000
            if messages.count > maxMessages {
                messages.removeFirst(messages.count - maxMessages)
            }
        }
    }
    
    @Published var isRunning = false
    @Published var statusMessage = ""
    
    /// Clears all console messages
    func clear() {
        messages.removeAll()
    }
    
    /// Updates the running state and status message
    /// - Parameters:
    ///   - isRunning: Whether a command is currently running
    ///   - status: The status message to display
    func updateStatus(isRunning: Bool, status: String? = nil) {
        DispatchQueue.main.async {
            self.isRunning = isRunning
            if let status = status {
                self.statusMessage = status
            }
        }
    }
}

// MARK: - Previews

struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ConsoleViewModel()
        
        // Add sample messages directly to the messages array
        viewModel.messages = [
            ConsoleMessage(text: "Starting Exino...", type: .info),
            ConsoleMessage(text: "Checking dependencies...", type: .info),
            ConsoleMessage(text: "Wine found at /usr/local/bin/wine64", type: .success),
            ConsoleMessage(text: "Homebrew not found", type: .warning),
            ConsoleMessage(text: "Failed to create Wine prefix: Permission denied", type: .error),
            ConsoleMessage(text: "Installation complete!", type: .success)
        ]
        
        return ConsoleView(viewModel: viewModel)
            .preferredColorScheme(.dark)
    }
}
