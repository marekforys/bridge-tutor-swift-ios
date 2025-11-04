import SwiftUI

struct BiddingGuideView: View {
    let sections: [(title: String, items: [String])] = [
        ("Polish Club (system)", [
            "1♣: strong, artificial (typically 12+ HCP)",
            "1♦: natural, 4+ ♦, ~11–17 HCP",
            "1♥/1♠: natural, usually 5+ cards",
            "1NT: 15–17 HCP, balanced",
            "Responses to 1♣: 1♦ = waiting/negative; 1♥/1♠ = 8+ HCP, 4+ suit"
        ]),
        ("Standard American (system)", [
            "5‑card majors: 1♥/1♠ show 5+",
            "1NT: 15–17 HCP, balanced",
            "Minors 1♣/1♦ natural, typically 3+",
            "Raises: single = 6–9, limit = 10–12",
            "New suit at 1‑level = 6+ HCP; at 2‑level = 10+"
        ]),
        ("2/1 Game Forcing (system)", [
            "2/1 response (e.g., 1♠–2♦) creates a game‑forcing auction",
            "Often uses forcing 1NT response",
            "Opener rebids clarify shape/strength",
            "Use cue‑bids/splinters to show shortness and slam interest"
        ]),
        ("Stayman over 1NT (convention)", [
            "2♣ asks for a 4‑card major",
            "2♦ = no 4‑card major",
            "2♥ = 4♥ (may also hold 4♠)",
            "2♠ = 4♠",
            "Responder sets fit, invites or bids game based on HCP"
        ]),
        ("Jacoby Transfers over 1NT (convention)", [
            "2♦ transfers to ♥; opener bids 2♥",
            "2♥ transfers to ♠; opener bids 2♠",
            "Responder: invite with 2NT/3M; GF with 3M or new suit",
            "Opener may super‑accept with 4‑card support and maximum"
        ]),
        ("RKCB 1430 (convention)", [
            "4NT = keycard ask in agreed trump suit",
            "5♣ = 1 or 4; 5♦ = 0 or 3 keycards",
            "5♥ often asks for trump queen or for specific kings",
            "Cue‑bid first‑round controls before keycard when helpful"
        ])
    ]

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

            List {
                ForEach(0..<sections.count, id: \.self) { i in
                    Section(header: Text(sections[i].title)) {
                        ForEach(sections[i].items, id: \.self) { item in
                            coloredSuitText(item)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Bidding Guide")
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
    NavigationView { BiddingGuideView() }
}
