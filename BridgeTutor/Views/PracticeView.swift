import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var gameManager: BridgeGameManager
    @State private var selectedBid: BidType? = nil

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

            // Bidding proposals
            VStack(spacing: 8) {
                // Suggested bid
                if let suggestion = gameManager.getSuggestedBid() {
                    Text("Suggested: \(suggestion.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    Menu {
                        // List only valid contracts to keep menu concise
                        ForEach(1...7, id: \.self) { level in
                            ForEach(Strain.allCases, id: \.self) { strain in
                                let bid = BidType.contract(level: level, strain: strain)
                                if gameManager.isValidBid(bid) {
                                    Button(bid.displayName) { selectedBid = bid }
                                }
                            }
                        }
                    } label: {
                        Text(selectedBid?.displayName ?? "Choose Bid")
                            .font(.body)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    Button("Bid") {
                        if let bid = selectedBid, gameManager.isValidBid(bid) {
                            gameManager.makeBid(bid)
                            selectedBid = nil
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled({
                        guard let bid = selectedBid else { return true }
                        return !gameManager.isValidBid(bid)
                    }())
                }

                HStack(spacing: 12) {
                    Button("Pass") { gameManager.makeBid(.pass) }
                        .buttonStyle(.bordered)

                    Button("Double") { gameManager.makeBid(.double) }
                        .buttonStyle(.bordered)
                        .disabled(!gameManager.isValidBid(.double))

                    Button("Redouble") { gameManager.makeBid(.redouble) }
                        .buttonStyle(.bordered)
                        .disabled(!gameManager.isValidBid(.redouble))
                }
            }

            // Bidding history and turn
            if !gameManager.biddingHistory.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bidding History")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(gameManager.biddingHistory, id: \.id) { bid in
                                VStack(spacing: 4) {
                                    Text(bid.player.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(bid.bid.displayName)
                                        .font(.body)
                                }
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }

            Text("\(gameManager.currentPlayer.rawValue)'s turn")
                .font(.subheadline)
                .foregroundColor(.secondary)

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
