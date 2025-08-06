import SwiftUI

struct AppMover {
    static func moveToApplicationsFolderIfNeeded(completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        let bundlePath = Bundle.main.bundleURL
        let applicationsURL = fileManager.urls(for: .applicationDirectory, in: .localDomainMask).first!
        let destinationURL = applicationsURL.appendingPathComponent(bundlePath.lastPathComponent)

        if !fileManager.fileExists(atPath: applicationsURL.path) {
            // Applications folder doesn't exist, this is unusual
            completion(false)
            return
        }

        // Don't move if already in Applications
        if bundlePath.deletingLastPathComponent() == applicationsURL {
            completion(true)
            return
        }

        // Check if we've already asked
        if UserDefaults.standard.bool(forKey: "dontAskToMove") {
            completion(true)
            return
        }

        let alert = NSAlert()
        alert.messageText = "Move to Applications folder?"
        alert.informativeText = "I can move myself to the Applications folder if you'd like."
        alert.addButton(withTitle: "Move to Applications Folder")
        alert.addButton(withTitle: "Do Not Move")
        alert.showsSuppressionButton = true

        let response = alert.runModal()

        if alert.suppressionButton?.state == .on {
            UserDefaults.standard.set(true, forKey: "dontAskToMove")
        }

        if response == .alertFirstButtonReturn {
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try fileManager.copyItem(at: bundlePath, to: destinationURL)
                    // Relaunch from new location
                    NSWorkspace.shared.open(destinationURL)
                    exit(0)
                } catch {
                    DispatchQueue.main.async {
                        let errorAlert = NSAlert()
                        errorAlert.messageText = "Failed to Move Application"
                        errorAlert.informativeText = error.localizedDescription
                        errorAlert.runModal()
                        completion(false)
                    }
                }
            }
        } else {
            completion(true)
        }
    }
}
