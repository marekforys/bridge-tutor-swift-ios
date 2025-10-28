import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var gameManager: BridgeGameManager

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button("New Hand") { gameManager.dealNewHand() }
                    .buttonStyle(.bordered)
                Spacer()
            }

            Text("Your Hand (\(gameManager.currentHand.highCardPoints) HCP)")
                .font(.headline)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                    ForEach(gameManager.currentHand.cards, id: \.id) { card in
                        Text(card.displayName)
                            .frame(width: 44, height: 60)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Practice")
    }
}

#Preview {
    PracticeView()
        .environmentObject(BridgeGameManager())
}
