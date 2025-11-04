import SwiftUI

struct BiddingTutorialView: View {
    @EnvironmentObject var gameManager: BridgeGameManager

    var body: some View {
        List {
            Section(header: Text("Polish Club — basics")) {
                coloredSuitText("1♣: strong, artificial (typically 12+ HCP, wide range)")
                coloredSuitText("1♦: natural, 4+ ♦, ~11–17 HCP")
                coloredSuitText("1♥/1♠: natural, 5+ cards")
                coloredSuitText("1NT: 15–17 HCP, balanced")
            }
            Section(header: Text("Responses to 1♣")) {
                coloredSuitText("1♦: 0–7 HCP (waiting/negative)")
                coloredSuitText("1♥/1♠: 8+ HCP, 4+ cards")
                coloredSuitText("1NT: 8–10 balanced (no 4-card major)")
                coloredSuitText("2♣/2♦: natural, 5+ suit, game-forcing values")
            }
            Section(header: Text("Follow-ups (simplified)")) {
                coloredSuitText("After 1♣–1♦: opener clarifies strength/shape")
                coloredSuitText("Raise responder’s major with 3+ support")
                coloredSuitText("Bid new suit naturally; notrump shows balanced ranges")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Tutorials")
    }
}

private func coloredSuitText(_ text: String) -> Text {
    var combined = Text("")
    for ch in text {
        let t = Text(String(ch)).foregroundColor((ch == "♥" || ch == "♦") ? .red : .primary)
        combined = combined + t
    }
    return combined
}

#Preview {
    NavigationView { BiddingTutorialView() }
        .environmentObject(BridgeGameManager())
}
