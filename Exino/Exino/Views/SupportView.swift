import SwiftUI

struct SupportView: View {
    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).edgesIgnoringSafeArea(.all)
            
            Text("Support")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .navigationTitle("Support")
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
            .preferredColorScheme(.dark)
    }
}
