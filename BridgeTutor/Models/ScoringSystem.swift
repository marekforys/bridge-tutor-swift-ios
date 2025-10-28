import Foundation

// MARK: - Scoring
struct BridgeScore {
    let contract: Contract
    let tricksTaken: Int
    let vulnerability: Vulnerability

    var result: ScoreResult {
        let required = contract.totalTricks
        if tricksTaken >= required { return .made(overtricks: tricksTaken - required) }
        return .down(undertricks: required - tricksTaken)
    }

    var points: Int {
        switch result {
        case .made(let over):
            return calculateMadeScore(overtricks: over)
        case .down(let under):
            return -calculateDownPenalty(undertricks: under)
        }
    }

    private func calculateMadeScore(overtricks: Int) -> Int {
        var score = 0
        // Contract trick score
        switch contract.strain {
        case .notrump:
            score += 40 + max(0, contract.level - 1) * 30
        case .hearts, .spades:
            score += contract.level * 30
        case .clubs, .diamonds:
            score += contract.level * 20
        }

        // Overtricks (simplified)
        let overValue: Int = {
            switch contract.strain {
            case .clubs, .diamonds: return 20
            case .hearts, .spades, .notrump: return 30
            }
        }()
        score += overtricks * overValue

        // Game/part-score bonus (simplified)
        if score >= 100 { score += (vulnerability == .both ? 500 : 300) }
        else { score += 50 }

        return score
    }

    private func calculateDownPenalty(undertricks: Int) -> Int {
        let base = (vulnerability == .both ? 100 : 50)
        return undertricks * base
    }
}

enum ScoreResult { case made(overtricks: Int), down(undertricks: Int) }

class ScoreManager: ObservableObject {
    @Published var scores: [BridgeScore] = []
    @Published var totalScore: Int = 0

    func addScore(_ s: BridgeScore) { scores.append(s); totalScore += s.points }
    func resetScores() { scores = []; totalScore = 0 }
}
