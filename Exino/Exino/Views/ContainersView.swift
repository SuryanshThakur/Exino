import SwiftUI

struct ContainersView: View {
    @EnvironmentObject var containerManager: ContainerManager
    @State private var showingAddContainerSheet = false

    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).edgesIgnoringSafeArea(.all)
            
            if containerManager.containers.isEmpty {
                Text("No containers created.")
                    .foregroundColor(.secondary)
            } else {
                List(containerManager.containers) { container in
                    Text(container.name)
                }
            }
        }
        .navigationTitle("Containers")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddContainerSheet = true }) {
                    Label("Add Container", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddContainerSheet) {
            AddContainerView()
                .environmentObject(containerManager)
        }
    }
}

struct ContainersView_Previews: PreviewProvider {
    static var previews: some View {
        ContainersView()
            .preferredColorScheme(.dark)
    }
}
