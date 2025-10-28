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

    private let deck = createDeck()

    init() { dealNewHand() }

    func dealNewHand() {
        let shuffled = deck.shuffled()
        currentHand = Hand(cards: Array(shuffled.prefix(13)))
        biddingHistory = []
        currentPlayer = .north
        gameState = .bidding
        contract = nil
    }

    func makeBid(_ bidType: BidType) {
        let bid = Bid(player: currentPlayer, bid: bidType)
        biddingHistory.append(bid)

        if isAuctionComplete() { finalizeContract() }
        else { currentPlayer = currentPlayer.next }
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

    func getSuggestedBid() -> BidType? {
        let hcp = currentHand.highCardPoints
        let longest = currentHand.longestSuit
        let len = currentHand.longestSuitLength
        let balanced = currentHand.isBalanced

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
}
