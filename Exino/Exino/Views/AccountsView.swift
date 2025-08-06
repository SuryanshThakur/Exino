import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var epicGamesAuthViewModel: EpicGamesAuthViewModel
    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Connect your accounts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                HStack(spacing: 20) {
                    AccountCard(accountType: .epic)
                    AccountCard(accountType: .steam)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Accounts")
    }
}

enum AccountType {
    case epic
    case steam
    
    var name: String {
        switch self {
        case .epic: return "Epic Games"
        case .steam: return "Steam"
        }
    }
    
    var logo: String {
        switch self {
        case .epic: return "cart.fill" // Placeholder icon
        case .steam: return "cloud.fill" // Placeholder icon
        }
    }
}

struct AccountCard: View {
    @EnvironmentObject var epicGamesAuthViewModel: EpicGamesAuthViewModel
    let accountType: AccountType
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: accountType.logo)
                    .font(.largeTitle)
                Text(accountType.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Spacer()
            
            if accountType == .epic {
                if epicGamesAuthViewModel.isAuthenticated {
                    Text("Connected")
                        .foregroundColor(.green)
                } else {
                    Button(action: {
                        epicGamesAuthViewModel.connect()
                    }) {
                        Text("Connect")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                }
            } else if accountType == .steam {
                Text("Coming Soon")
                   .foregroundColor(.secondary)
            }
    
        }
        .padding()
        .frame(width: 300, height: 150)
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView()
            .preferredColorScheme(.dark)
    }
}
