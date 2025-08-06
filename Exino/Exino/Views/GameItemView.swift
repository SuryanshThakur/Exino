import SwiftUI

struct GameItemView: View {
    let game: EpicGame

    var body: some View {
        Button(action: {
            print("Clicked on game: \(game.name)")
        }) {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .aspectRatio(3/4, contentMode: .fit)
                        .cornerRadius(8)
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                
                Text(game.name)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
