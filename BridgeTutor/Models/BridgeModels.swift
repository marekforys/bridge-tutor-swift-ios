import Foundation

// MARK: - Strain (Suits + Notrump)
enum Strain: String, CaseIterable, Codable, Hashable {
    case clubs = "♣"
    case diamonds = "♦"
    case hearts = "♥"
    case spades = "♠"
    case notrump = "NT"

    var order: Int {
        switch self {
        case .clubs: return 1
        case .diamonds: return 2
        case .hearts: return 3
        case .spades: return 4
        case .notrump: return 5
        }
    }

    var isMajor: Bool { self == .hearts || self == .spades }
    var isMinor: Bool { self == .clubs || self == .diamonds }
}

// MARK: - Card Models
enum Suit: String, CaseIterable, Codable {
    case spades = "♠"
    case hearts = "♥"
    case diamonds = "♦"
    case clubs = "♣"

    var color: CardColor {
        switch self {
        case .spades, .clubs: return .black
        case .hearts, .diamonds: return .red
        }
    }

    var order: Int {
        switch self {
        case .clubs: return 1
        case .diamonds: return 2
        case .hearts: return 3
        case .spades: return 4
        }
    }
}

enum CardColor { case red, black }

enum Rank: String, CaseIterable, Codable {
    case ace = "A", king = "K", queen = "Q", jack = "J"
    case ten = "10", nine = "9", eight = "8", seven = "7", six = "6", five = "5", four = "4", three = "3", two = "2"

    var value: Int {
        switch self {
        case .ace: return 14
        case .king: return 13
        case .queen: return 12
        case .jack: return 11
        case .ten: return 10
        case .nine: return 9
        case .eight: return 8
        case .seven: return 7
        case .six: return 6
        case .five: return 5
        case .four: return 4
        case .three: return 3
        case .two: return 2
        }
    }

    var highCardPoints: Int {
        switch self {
        case .ace: return 4
        case .king: return 3
        case .queen: return 2
        case .jack: return 1
        default: return 0
        }
    }
}

struct Card: Identifiable, Codable, Equatable {
    var id = UUID()
    let suit: Suit
    let rank: Rank

    var displayName: String { "\(rank.rawValue)\(suit.rawValue)" }
    var highCardPoints: Int { rank.highCardPoints }
}

// MARK: - Hand
struct Hand: Identifiable, Codable {
    var id = UUID()
    var cards: [Card]

    init(cards: [Card] = []) { self.cards = cards }

    var highCardPoints: Int { cards.reduce(0) { $0 + $1.highCardPoints } }

    var distribution: [Suit: Int] {
        var dist: [Suit: Int] = [:]
        for suit in Suit.allCases { dist[suit] = cards.filter { $0.suit == suit }.count }
        return dist
    }

    var longestSuit: Suit? { distribution.max(by: { $0.value < $1.value })?.key }
    var longestSuitLength: Int { distribution.values.max() ?? 0 }

    var isBalanced: Bool {
        let counts = distribution.values.sorted(by: >)
        guard counts.count == 4 else { return false }
        let pattern = counts.map { String($0) }.joined(separator: "-")
        return pattern == "4-3-3-3" || pattern == "4-4-3-2"
    }

    func cardsInSuit(_ suit: Suit) -> [Card] {
        cards.filter { $0.suit == suit }.sorted { $0.rank.value > $1.rank.value }
    }
}

// MARK: - Bidding
enum BidType: Codable, Equatable {
    case pass
    case double
    case redouble
    case contract(level: Int, strain: Strain)

    var displayName: String {
        switch self {
        case .pass: return "Pass"
        case .double: return "X"
        case .redouble: return "XX"
        case .contract(let level, let strain):
            return strain == .notrump ? "\(level)NT" : "\(level)\(strain.rawValue)"
        }
    }

    var isContract: Bool { if case .contract = self { return true } else { return false } }

    var contractLevel: Int? { if case .contract(let l, _) = self { return l } else { return nil } }
    var contractStrain: Strain? { if case .contract(_, let s) = self { return s } else { return nil } }
}

struct Bid: Identifiable, Codable {
    var id = UUID()
    let player: Player
    let bid: BidType
    let timestamp: Date

    init(player: Player, bid: BidType) {
        self.player = player
        self.bid = bid
        self.timestamp = Date()
    }
}

// MARK: - Player
enum Player: String, CaseIterable, Codable {
    case north = "North", east = "East", south = "South", west = "West"

    var next: Player {
        switch self { case .north: return .east; case .east: return .south; case .south: return .west; case .west: return .north }
    }
    var partner: Player {
        switch self { case .north: return .south; case .east: return .west; case .south: return .north; case .west: return .east }
    }
}

// MARK: - Contract
struct Contract: Codable {
    let level: Int
    let strain: Strain
    let declarer: Player
    let isDoubled: Bool
    let isRedoubled: Bool

    var displayName: String {
        var name = strain == .notrump ? "\(level)NT" : "\(level)\(strain.rawValue)"
        if isRedoubled { name += " XX" } else if isDoubled { name += " X" }
        return name
    }

    var totalTricks: Int { level + 6 }

    var trickScore: Int {
        switch strain {
        case .clubs, .diamonds:
            return level * 20
        case .hearts, .spades:
            return level * 30
        case .notrump:
            return 40 + max(0, level - 1) * 30
        }
    }
}
