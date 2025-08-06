import SwiftUI

struct StoreView: View {
    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).edgesIgnoringSafeArea(.all)
            
            Text("Store")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .navigationTitle("Store")
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
            .preferredColorScheme(.dark)
    }
}
