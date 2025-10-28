import Foundation
import SwiftUI

// MARK: - Game State
enum GameState { case bidding, play, finished }

enum Vulnerability { case none, northSouth, eastWest, both }

// MARK: - Deck
func createDeck() -> [Card] {
    var deck: [Card] = []
    for suit in Suit.allCases {
        for rank in Rank.allCases {
            deck.append(Card(suit: suit, rank: rank))
        }
    }
    return deck
}

// MARK: - Game Manager
class BridgeGameManager: ObservableObject {
    @Published var currentHand: Hand = Hand()
    @Published var biddingHistory: [Bid] = []
    @Published var currentPlayer: Player = .north
    @Published var gameState: GameState = .bidding
    @Published var contract: Contract?
    @Published var vulnerability: Vulnerability = .none
    @Published var userSeat: Player = .south

    private var playerHands: [Player: Hand] = [:]

    private let deck = createDeck()

    init() { dealNewHand() }

    func dealNewHand() {
        // Deal 13 cards to each player
        var shuffled = deck.shuffled()
        var hands: [Player: [Card]] = [.north: [], .east: [], .south: [], .west: []]
        let order: [Player] = [.north, .east, .south, .west]
        var idx = 0
        while idx < 52 {
            for p in order { if idx < 52 { hands[p, default: []].append(shuffled[idx]); idx += 1 } }
        }
        playerHands = hands.mapValues { Hand(cards: $0) }

        // Set user's current hand
        if let hand = playerHands[userSeat] { currentHand = hand }

        // Reset auction state
        biddingHistory = []
        currentPlayer = .north // dealer can be enhanced later
        gameState = .bidding
        contract = nil

        // Let AI bid until it's user's turn
        maybeAutoAdvance()
    }

    func makeBid(_ bidType: BidType) {
        appendBid(bidType)
        if isAuctionComplete() {
            finalizeContract()
            return
        }
        // After a user bid, let AI respond until it's user's turn again
        maybeAutoAdvance()
    }

    private func appendBid(_ bidType: BidType) {
        let bid = Bid(player: currentPlayer, bid: bidType)
        biddingHistory.append(bid)
        if !isAuctionComplete() { currentPlayer = currentPlayer.next }
    }

    private func isAuctionComplete() -> Bool {
        // Completed when there is a contract followed by three passes
        guard let lastContractIndex = biddingHistory.lastIndex(where: { $0.bid.isContract }) else { return false }
        let tail = biddingHistory.suffix(from: biddingHistory.index(after: lastContractIndex))
        return tail.count >= 3 && tail.allSatisfy { if case .pass = $0.bid { return true } else { return false } }
    }

    private func lastNonPassBid() -> Bid? { biddingHistory.last(where: { if case .pass = $0.bid { return false } else { return true } }) }

    private func finalizeContract() {
        guard let lastContractBid = biddingHistory.last(where: { $0.bid.isContract }) else { return }
        if case .contract(let level, let strain) = lastContractBid.bid {
            let isDoubled = biddingHistory.contains { if case .double = $0.bid { return true } else { return false } }
            let isRedoubled = biddingHistory.contains { if case .redouble = $0.bid { return true } else { return false } }
            contract = Contract(level: level, strain: strain, declarer: lastContractBid.player, isDoubled: isDoubled, isRedoubled: isRedoubled)
            gameState = .play
        }
    }

    func isValidBid(_ bidType: BidType) -> Bool {
        if biddingHistory.isEmpty { return true }
        guard let lastBid = lastNonPassBid() else { return true }

        switch bidType {
        case .pass:
            return true
        case .double:
            if case .contract = lastBid.bid { return lastBid.player != currentPlayer }
            return false
        case .redouble:
            if case .double = lastBid.bid { return lastBid.player != currentPlayer }
            return false
        case .contract(let level, let strain):
            if case .contract(let lastLevel, let lastStrain) = lastBid.bid {
                if level > lastLevel { return true }
                if level == lastLevel { return strain.order > lastStrain.order }
                return false
            }
            return true
        }
    }

    // Suggestion for the user's hand (for UI hint)
    func getSuggestedBid() -> BidType? {
        return suggestBid(for: currentHand)
    }

    // Core suggestion logic used by AI and UI
    private func suggestBid(for hand: Hand) -> BidType {
        let hcp = hand.highCardPoints
        let len = hand.longestSuitLength
        let balanced = hand.isBalanced
        let longest = hand.longestSuit

        if hcp >= 15 && hcp <= 17 && balanced { return .contract(level: 1, strain: .notrump) }
        if hcp >= 12 {
            if let suit = longest, len >= 5 {
                let strain: Strain = (suit == .hearts ? .hearts : suit == .spades ? .spades : suit == .diamonds ? .diamonds : .clubs)
                return .contract(level: 1, strain: strain)
            }
            if balanced { return .contract(level: 1, strain: .notrump) }
        }
        if hcp >= 20 && balanced { return .contract(level: 2, strain: .notrump) }
        if hcp >= 6 && len >= 6, let suit = longest {
            let strain: Strain = (suit == .hearts ? .hearts : suit == .spades ? .spades : suit == .diamonds ? .diamonds : .clubs)
            return .contract(level: 2, strain: strain)
        }
        return .pass
    }

    // Advance AI bids until it is user's turn or auction completes
    private func maybeAutoAdvance() {
        // Keep currentHand synced to user's seat
        if let hand = playerHands[userSeat] { currentHand = hand }

        while currentPlayer != userSeat && !isAuctionComplete() {
            guard let hand = playerHands[currentPlayer] else { break }
            var bid = suggestBid(for: hand)
            if !isValidBid(bid) { bid = .pass }
            appendBid(bid)
        }

        if isAuctionComplete() { finalizeContract() }
    }
}
