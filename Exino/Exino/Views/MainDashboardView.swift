import SwiftUI

struct MainDashboardView: View {
    @EnvironmentObject var exinoViewModel: ExinoViewModel
    @EnvironmentObject var containerManager: ContainerManager
    @State private var selection: SidebarItem? = .home

    var body: some View {
        NavigationView {
            Sidebar(selection: $selection)
            
            switch selection {
            case .home:
                HomeView()
            case .library:
                LibraryView()
                    .environmentObject(exinoViewModel)
            case .store:
                StoreView()
            case .containers:
                ContainersView()
                    .environmentObject(containerManager)
            case .support:
                SupportView()
            case .accounts:
                AccountsView()
            case .none:
                Text("Select an item from the sidebar")
            }
        }
    }
}

enum SidebarItem: String, CaseIterable, Hashable {
    case home = "Home"
    case library = "Library"
    case store = "Store"
    case containers = "Containers"
    case support = "Support"
    case accounts = "Accounts"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .library: return "gamecontroller.fill"
        case .store: return "cart.fill"
        case .containers: return "shippingbox.fill"
        case .support: return "lifepreserver.fill"
        case .accounts: return "person.crop.circle.fill"
        }
    }
}

struct Sidebar: View {
    @Binding var selection: SidebarItem?
    @EnvironmentObject var exinoViewModel: ExinoViewModel
    @EnvironmentObject var containerManager: ContainerManager

    var body: some View {
        List(selection: $selection) {
            Section(header: Text("Dashboard")) {
                ForEach([SidebarItem.home, .library, .store], id: \.self) { item in
                    NavigationLink(destination: view(for: item), tag: item, selection: $selection) {
                        Label(item.rawValue, systemImage: item.icon)
                    }
                }
            }
            
            Section(header: Text("Management")) {
                ForEach([SidebarItem.containers, .support, .accounts], id: \.self) { item in
                    NavigationLink(destination: view(for: item), tag: item, selection: $selection) {
                        Label(item.rawValue, systemImage: item.icon)
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
    }
    
    @ViewBuilder
    private func view(for item: SidebarItem) -> some View {
        switch item {
        case .home: HomeView()
        case .library: LibraryView()
        case .store: StoreView()
        case .containers: ContainersView()
        case .support: SupportView()
        case .accounts: AccountsView()
        }
    }
}



// MARK: - Preview
struct MainDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MainDashboardView()
            .environmentObject(ExinoViewModel())
            .environmentObject(ContainerManager())
            .environmentObject(EpicGamesAuthViewModel())
            .preferredColorScheme(.dark)
    }
}

