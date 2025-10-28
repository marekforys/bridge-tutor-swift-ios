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
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([Suit.spades, .hearts, .diamonds, .clubs], id: \.self) { suit in
                        let cards = gameManager.currentHand.cards
                            .filter { $0.suit == suit }
                            .sorted { $0.rank.value > $1.rank.value }

                        if !cards.isEmpty {
                            HStack(alignment: .center, spacing: 8) {
                                Text(suit.rawValue)
                                    .font(.headline)
                                    .foregroundColor((suit == .hearts || suit == .diamonds) ? .red : .primary)

                                ForEach(cards, id: \.id) { card in
                                    Text(card.displayName)
                                        .foregroundColor(card.suit.color == .red ? .red : .primary)
                                        .frame(width: 44, height: 60)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                Spacer(minLength: 0)
                            }
                        }
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
