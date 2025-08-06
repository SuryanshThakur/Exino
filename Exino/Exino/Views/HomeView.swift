import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("★ No games are favourited.")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Home")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}
