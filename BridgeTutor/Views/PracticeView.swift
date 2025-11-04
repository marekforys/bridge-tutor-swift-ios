import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var gameManager: BridgeGameManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBid: BidType? = nil
    @State private var showingBidSheet: Bool = false
    @State private var showingAllHands: Bool = false

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
                Button("Show All Hands") { showingAllHands = true }
                    .buttonStyle(.bordered)
                Spacer()
                SystemBadge(system: gameManager.activeSystem)
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
                        .disabled(!gameManager.isValidBid(.pass))

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
            .sheet(isPresented: $showingAllHands) {
                NavigationView { HandsReviewView() }
                    .environmentObject(gameManager)
            }
        }
    }
}

private struct CenterInfoPanel: View {
    let dealer: Player
    let vulnerability: String
    let contract: String?

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 6) {
                Text("Dealer")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                CompassBadge(label: dealerLabel(dealer))
                Divider().background(Color.white.opacity(0.2))
                Text("Vulnerability")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                CompassBadge(label: vulnerability)
                if let contract = contract {
                    Divider().background(Color.white.opacity(0.2))
                    Text("Contract")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    CompassBadge(label: contract)
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.15), lineWidth: 1))
            .cornerRadius(12)
        }
        .frame(minWidth: 120)
    }

    private func dealerLabel(_ p: Player) -> String {
        switch p {
        case .north: return "N"
        case .east: return "E"
        case .south: return "S"
        case .west: return "W"
        }
    }
}

private struct CompassBadge: View {
    let label: String
    var body: some View {
        Text(label)
            .font(.caption2).bold()
            .foregroundColor(.white)
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .background(Color.white.opacity(0.18))
            .overlay(
                Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .clipShape(Capsule())
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

private struct SystemBadge: View {
    let system: BridgeGameManager.BiddingSystem
    private func label(for sys: BridgeGameManager.BiddingSystem) -> String {
        switch sys {
        case .standardAmerican: return "Standard American"
        case .polishClub: return "Polish Club"
        case .twoOverOne: return "2/1 GF"
        }
    }
    var body: some View {
        Text(label(for: system))
            .font(.caption2)
            .foregroundColor(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.white.opacity(0.15))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.white.opacity(0.2), lineWidth: 1))
            .cornerRadius(9)
    }
}

private struct HandsReviewView: View {
    @EnvironmentObject var gameManager: BridgeGameManager

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

            VStack(spacing: 16) {
                // North (top)
                if let hand = hand(for: .north) {
                    CompassBadge(label: "N")
                    HandPanel(title: "North — \(hand.highCardPoints) HCP") {
                        suitRow(title: "♠", suit: .spades, hand: hand)
                        suitRow(title: "♥", suit: .hearts, hand: hand)
                        suitRow(title: "♦", suit: .diamonds, hand: hand)
                        suitRow(title: "♣", suit: .clubs, hand: hand)
                    }
                }

                HStack(spacing: 16) {
                    // West (left)
                    if let hand = hand(for: .west) {
                        VStack(spacing: 6) {
                            CompassBadge(label: "W")
                            HandPanel(title: "West — \(hand.highCardPoints) HCP") {
                                suitRow(title: "♠", suit: .spades, hand: hand)
                                suitRow(title: "♥", suit: .hearts, hand: hand)
                                suitRow(title: "♦", suit: .diamonds, hand: hand)
                                suitRow(title: "♣", suit: .clubs, hand: hand)
                            }
                        }
                    }

                    // Center info (dealer, vulnerability, contract)
                    CenterInfoPanel(dealer: dealerSeat(), vulnerability: vulnerabilityLabel(), contract: contractLabel())

                    // East (right)
                    if let hand = hand(for: .east) {
                        VStack(spacing: 6) {
                            CompassBadge(label: "E")
                            HandPanel(title: "East — \(hand.highCardPoints) HCP") {
                                suitRow(title: "♠", suit: .spades, hand: hand)
                                suitRow(title: "♥", suit: .hearts, hand: hand)
                                suitRow(title: "♦", suit: .diamonds, hand: hand)
                                suitRow(title: "♣", suit: .clubs, hand: hand)
                            }
                        }
                    }
                }

                // South (bottom)
                if let hand = hand(for: .south) {
                    CompassBadge(label: "S")
                    HandPanel(title: "South — \(hand.highCardPoints) HCP") {
                        suitRow(title: "♠", suit: .spades, hand: hand)
                        suitRow(title: "♥", suit: .hearts, hand: hand)
                        suitRow(title: "♦", suit: .diamonds, hand: hand)
                        suitRow(title: "♣", suit: .clubs, hand: hand)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("All Hands")
    }

    private func hand(for player: Player) -> Hand? { gameManager.allHands()[player] }

    private func dealerSeat() -> Player {
        if let first = gameManager.biddingHistory.first { return first.player }
        return .north
    }

    private func vulnerabilityLabel() -> String {
        switch gameManager.vulnerability {
        case .none: return "None"
        case .northSouth: return "N-S"
        case .eastWest: return "E-W"
        case .both: return "Both"
        }
    }

    private func contractLabel() -> String? {
        if let c = gameManager.contract { return c.displayName }
        return nil
    }

    private func suitRow(title: String, suit: Suit, hand: Hand) -> some View {
        let cards = hand.cards
            .filter { $0.suit == suit }
            .sorted { $0.rank.value > $1.rank.value }
        return HStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor((suit == .hearts || suit == .diamonds) ? .red : .primary)
            Text(cards.map { $0.rank.rawValue }.joined(separator: " "))
                .foregroundColor((suit == .hearts || suit == .diamonds) ? .red : .primary)
        }
    }
}

private struct HandPanel<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 4) {
                content
            }
            .padding(10)
            .background(Color.white.opacity(0.12))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.15), lineWidth: 1))
            .cornerRadius(10)
        }
    }
}
