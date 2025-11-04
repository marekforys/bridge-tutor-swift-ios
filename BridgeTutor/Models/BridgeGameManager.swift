import Foundation

// MARK: - Practice presets for targeted drills
enum PracticePreset: Codable, Equatable {
    case polishClub
    case standardAmerican
    case twoOverOne
    case stayman
    case jacobyTransfers
    case rkcb
}
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
    @Published var practicePreset: PracticePreset? = nil

    private var playerHands: [Player: Hand] = [:]

    private let deck = createDeck()

    init() { dealNewHand() }

    func dealNewHand() {
        // Attempt biased dealing if a preset is set
        let attemptsLimit = 400
        var attempt = 0
        var found = false
        while attempt < attemptsLimit {
            attempt += 1
            let shuffled = deck.shuffled()
            var hands: [Player: [Card]] = [.north: [], .east: [], .south: [], .west: []]
            let order: [Player] = [.north, .east, .south, .west]
            var idx = 0
            while idx < 52 {
                for p in order { if idx < 52 { hands[p, default: []].append(shuffled[idx]); idx += 1 } }
            }
            let built = hands.mapValues { Hand(cards: $0) }

            if let preset = practicePreset {
                if satisfiesPreset(built, preset: preset) {
                    playerHands = built
                    found = true
                    break
                }
            } else {
                playerHands = built
                found = true
                break
            }
        }

        if !found {
            // Fallback to random if preset was too strict
            let shuffled = deck.shuffled()
            var hands: [Player: [Card]] = [.north: [], .east: [], .south: [], .west: []]
            let order: [Player] = [.north, .east, .south, .west]
            var idx = 0
            while idx < 52 {
                for p in order { if idx < 52 { hands[p, default: []].append(shuffled[idx]); idx += 1 } }
            }
            playerHands = hands.mapValues { Hand(cards: $0) }
        }

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

    private func satisfiesPreset(_ hands: [Player: Hand], preset: PracticePreset) -> Bool {
        guard let south = hands[userSeat], let north = hands[userSeat.partner] else { return false }

        switch preset {
        case .polishClub:
            // Strong hand suitable for 1♣ opener: HCP >= 16, any shape (clubs 3+ preferred)
            let clubs = south.cards.filter { $0.suit == .clubs }.count
            return south.highCardPoints >= 16 && clubs >= 3

        case .standardAmerican:
            // Encourage a 1M opening: 5+ major, 12–19 HCP
            let sp = south.cards.filter { $0.suit == .spades }.count
            let he = south.cards.filter { $0.suit == .hearts }.count
            return south.highCardPoints >= 12 && south.highCardPoints <= 19 && (sp >= 5 || he >= 5)

        case .twoOverOne:
            // Opener 5+ major, 12–17; partner values 12+ to create GF potential
            let sp = south.cards.filter { $0.suit == .spades }.count
            let he = south.cards.filter { $0.suit == .hearts }.count
            return south.highCardPoints >= 12 && south.highCardPoints <= 17 && (sp >= 5 || he >= 5) && north.highCardPoints >= 12

        case .stayman:
            // 1NT opener: 15–17 HCP balanced
            return south.highCardPoints >= 15 && south.highCardPoints <= 17 && south.isBalanced

        case .jacobyTransfers:
            // 1NT opener (south) and partner with a 5+ major to transfer
            let nSp = north.cards.filter { $0.suit == .spades }.count
            let nHe = north.cards.filter { $0.suit == .hearts }.count
            return south.highCardPoints >= 15 && south.highCardPoints <= 17 && south.isBalanced && (nSp >= 5 || nHe >= 5)

        case .rkcb:
            // Aim for an 8+ card major fit between N/S to encourage keycard exploration
            let sSp = south.cards.filter { $0.suit == .spades }.count
            let sHe = south.cards.filter { $0.suit == .hearts }.count
            let nSp = north.cards.filter { $0.suit == .spades }.count
            let nHe = north.cards.filter { $0.suit == .hearts }.count
            return (sSp + nSp) >= 8 || (sHe + nHe) >= 8
        }
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

    func getSuggestedBid() -> BidType? {
        let ctx = buildAuctionContext(for: userSeat)
        return suggestBid(for: currentHand, player: userSeat, context: ctx)
    }

    private struct AuctionContext {
        let player: Player
        let partner: Player
        let partnerLast: BidType?
        let ourLast: BidType?
        let oppLast: BidType?
        let lastContract: (player: Player, level: Int, strain: Strain)?
        let isCompetitive: Bool
        let weOpened: Bool
        let partnerOpened: Bool
    }

    private func buildAuctionContext(for player: Player) -> AuctionContext {
        let partner = player.partner

        func lastBid(by p: Player) -> BidType? {
            return biddingHistory.last(where: { $0.player == p })?.bid
        }

        func lastContractBid() -> (player: Player, level: Int, strain: Strain)? {
            guard let b = biddingHistory.last(where: { $0.bid.isContract }) else { return nil }
            if case .contract(let l, let s) = b.bid { return (b.player, l, s) }
            return nil
        }

        let partnerLast = lastBid(by: partner)
        let ourLast = lastBid(by: player)
        let oppLast = biddingHistory.last(where: { $0.player != player && $0.player != partner })?.bid
        let lastC = lastContractBid()

        let weOpened = biddingHistory.first(where: { $0.bid.isContract })?.player == player || biddingHistory.first(where: { $0.bid.isContract })?.player == partner
        let partnerOpened = biddingHistory.first(where: { $0.player == partner && $0.bid.isContract }) != nil
        let isCompetitive = biddingHistory.contains(where: { $0.player != player && $0.player != partner && $0.bid.isContract })

        return AuctionContext(player: player, partner: partner, partnerLast: partnerLast, ourLast: ourLast, oppLast: oppLast, lastContract: lastC, isCompetitive: isCompetitive, weOpened: weOpened, partnerOpened: partnerOpened)
    }

    private func suggestBid(for hand: Hand, player: Player, context: AuctionContext) -> BidType {
        let hcp = hand.highCardPoints
        let balanced = hand.isBalanced
        let longest = hand.longestSuit
        let counts: [Suit: Int] = [
            .spades: hand.cards.filter { $0.suit == .spades }.count,
            .hearts: hand.cards.filter { $0.suit == .hearts }.count,
            .diamonds: hand.cards.filter { $0.suit == .diamonds }.count,
            .clubs: hand.cards.filter { $0.suit == .clubs }.count
        ]

        func strainFrom(_ suit: Suit) -> Strain { suit == .spades ? .spades : suit == .hearts ? .hearts : suit == .diamonds ? .diamonds : .clubs }

        if biddingHistory.isEmpty || biddingHistory.allSatisfy({ if case .pass = $0.bid { return true } else { return false } }) {
            if hcp >= 15 && hcp <= 17 && balanced { return .contract(level: 1, strain: .notrump) }
            if hcp >= 12 {
                if let s = [.spades, .hearts].first(where: { counts[$0, default: 0] >= 5 }) { return .contract(level: 1, strain: strainFrom(s)) }
                if let s = longest { return .contract(level: 1, strain: strainFrom(s)) }
                if balanced { return .contract(level: 1, strain: .notrump) }
            }
            if hcp >= 20 && balanced { return .contract(level: 2, strain: .notrump) }
            if let s = longest, counts[s, default: 0] >= 6, hcp >= 6 { return .contract(level: 2, strain: strainFrom(s)) }
            return .pass
        }

        if case .contract(let lvl, let strain)? = context.partnerLast {
            if strain == .hearts || strain == .spades {
                let need = (strain == .hearts ? counts[.hearts, default: 0] : counts[.spades, default: 0])
                if need >= 3 {
                    if hcp >= 13 { return .contract(level: lvl + 3 >= 4 ? 4 : lvl + 1, strain: strain) }
                    if hcp >= 10 { return .contract(level: lvl + 2, strain: strain) }
                    if hcp >= 6 { return .contract(level: lvl + 1, strain: strain) }
                }
            }
            if strain == .clubs || strain == .diamonds {
                let suit: Suit = (strain == .clubs ? .clubs : .diamonds)
                if counts[suit, default: 0] >= 3 {
                    if hcp >= 13 { return .contract(level: lvl + 2, strain: strain) }
                    if hcp >= 10 { return .contract(level: lvl + 1, strain: strain) }
                }
            }
            if balanced {
                if hcp >= 13 { return .contract(level: 3, strain: .notrump) }
                if hcp >= 10 { return .contract(level: 2, strain: .notrump) }
                if hcp >= 6 { return .contract(level: 1, strain: .notrump) }
            }
            if let s = [.spades, .hearts, .diamonds, .clubs].first(where: { counts[$0, default: 0] >= 5 }) {
                return .contract(level: max(1, lvl), strain: strainFrom(s))
            }
            return .pass
        }

        if let opp = context.oppLast {
            if case .contract(_, let oppStrain) = opp {
                if let major = [.spades, .hearts].first(where: { counts[$0, default: 0] >= 5 }), hcp >= 8 {
                    return .contract(level: 1, strain: strainFrom(major))
                }
                let oppSuit: Suit? = (oppStrain == .spades ? .spades : oppStrain == .hearts ? .hearts : oppStrain == .diamonds ? .diamonds : oppStrain == .clubs ? .clubs : nil)
                if hcp >= 12, let o = oppSuit, hand.cards.filter({ $0.suit == o }).count <= 2 {
                    return .double
                }
            }
        }

        if let our = context.ourLast, case .contract(let lvl, let strain) = our {
            if let s = [.spades, .hearts].first(where: { counts[$0, default: 0] >= 5 && strainFrom($0) != strain }) {
                return .contract(level: max(1, lvl), strain: strainFrom(s))
            }
            if balanced {
                if hcp >= 18 { return .contract(level: 2, strain: .notrump) }
                if hcp >= 12 { return .contract(level: 1, strain: .notrump) }
            }
        }

        return .pass
    }

    // Advance AI bids until it is user's turn or auction completes
    private func maybeAutoAdvance() {
        // Keep currentHand synced to user's seat
        if let hand = playerHands[userSeat] { currentHand = hand }

        while currentPlayer != userSeat && !isAuctionComplete() {
            guard let hand = playerHands[currentPlayer] else { break }
            let ctx = buildAuctionContext(for: currentPlayer)
            var bid = suggestBid(for: hand, player: currentPlayer, context: ctx)
            if !isValidBid(bid) { bid = .pass }
            appendBid(bid)
        }

        if isAuctionComplete() { finalizeContract() }
    }
}
