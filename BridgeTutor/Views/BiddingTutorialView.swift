import SwiftUI

struct BiddingTutorialView: View {
    @EnvironmentObject var gameManager: BridgeGameManager

    var body: some View {
        VStack(spacing: 16) {
            Text("Tutorial")
                .font(.title2)
                .fontWeight(.bold)
            Text("Coming soon: interactive lessons, hints, and guided bidding.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .padding()
        .navigationTitle("Tutorial")
    }
}

#Preview {
    BiddingTutorialView()
        .environmentObject(BridgeGameManager())
}
