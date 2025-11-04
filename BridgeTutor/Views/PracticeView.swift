import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var gameManager: BridgeGameManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBid: BidType? = nil
    @State private var showingBidSheet: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.02, green: 0.35, blue: 0.18),
                    Color(red: 0.04, green: 0.45, blue: 0.24)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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
                    Button(action: { showingBidSheet = true }) {
                        HStack {
                            if case .contract(let level, let strain) = selectedBid {
                                Text("\(level)")
                                suitIconImage(for: strain)
                            } else {
                                Text("Choose Bid")
                            }
                        }
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showingBidSheet) {
                        NavigationView {
                            List {
                                ForEach(1...7, id: \.self) { level in
                                    ForEach(Strain.allCases, id: \.self) { strain in
                                        let bid = BidType.contract(level: level, strain: strain)
                                        Button(action: {
                                            if gameManager.isValidBid(bid) {
                                                selectedBid = bid
                                                showingBidSheet = false
                                            }
                                        }) {
                                            HStack(spacing: 8) {
                                                Text("\(level)")
                                                suitSymbolText(for: strain)
                                            }
                                        }
                                        .disabled(!gameManager.isValidBid(bid))
                                    }
                                }
                            }
                            .navigationTitle("Select Bid")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Close") { showingBidSheet = false }
                                }
                            }
                        }
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
                                    // Colored suits in history
                                    coloredBidText(bid.bid.displayName)
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
}

@ViewBuilder
private func suitColorDot(for strain: Strain) -> some View {
    let isRed = (strain == .hearts || strain == .diamonds)
    Circle()
        .fill(isRed ? Color.red : Color.primary)
        .frame(width: 8, height: 8)
}

private func suitSymbolName(for strain: Strain) -> String? {
    switch strain {
    case .hearts: return "suit.heart.fill"
    case .diamonds: return "suit.diamond.fill"
    case .spades: return "suit.spade.fill"
    case .clubs: return "suit.club.fill"
    case .notrump: return nil
    }
}

// MARK: - Helpers

private func coloredBidText(_ text: String) -> Text {
    var combined = Text("")
    for scalar in text.unicodeScalars {
        let ch = String(scalar)
        let isRed = ch == "♥" || ch == "♦"
        combined = combined + Text(ch).foregroundColor(isRed ? .red : .primary)
    }
    return combined
}

@ViewBuilder
private func suitSymbolText(for strain: Strain) -> some View {
    switch strain {
    case .hearts:
        Text("♥️")
    case .diamonds:
        Text("♦️")
    case .spades:
        Text("♠️")
    case .clubs:
        Text("♣️")
    case .notrump:
        Text("NT")
    }
}

private func suitText(for strain: Strain) -> String {
    switch strain {
    case .hearts: return "♥"
    case .diamonds: return "♦"
    case .spades: return "♠"
    case .clubs: return "♣"
    case .notrump: return "NT"
    }
}

@ViewBuilder
private func suitIconImage(for strain: Strain) -> some View {
    switch strain {
    case .hearts:
        Image(systemName: "suit.heart.fill").foregroundColor(.red)
    case .diamonds:
        Image(systemName: "suit.diamond.fill").foregroundColor(.red)
    case .spades:
        Image(systemName: "suit.spade.fill").foregroundColor(.primary)
    case .clubs:
        Image(systemName: "suit.club.fill").foregroundColor(.primary)
    case .notrump:
        Text("NT").foregroundColor(.primary)
    }
}

@ViewBuilder
private func menuBidLabel(level: Int, strain: Strain) -> some View {
    HStack(spacing: 6) {
        suitSymbolText(for: strain)
        Text("\(level)")
    }
}

#Preview {
    PracticeView()
        .environmentObject(BridgeGameManager())
}
