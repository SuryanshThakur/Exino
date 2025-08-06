import SwiftUI

struct AddContainerView: View {
    @EnvironmentObject var containerManager: ContainerManager
    @Environment(\.presentationMode) var presentationMode
    @State private var containerName = ""

    var body: some View {
        VStack {
            Text("Create New Container")
                .font(.title)
            TextField("Container Name", text: $containerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Create") {
                if !containerName.isEmpty {
                    containerManager.createContainer(name: containerName, wineVersion: "crossover") { result in
                        switch result {
                        case .success:
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            // Handle error appropriately, e.g., show an alert
                            print("Error creating container: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .disabled(containerName.isEmpty)
        }
        .padding()
    }
}
