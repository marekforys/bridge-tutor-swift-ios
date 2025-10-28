import SwiftUI

struct BiddingGuideView: View {
    let sections: [(title: String, items: [String])] = [
        ("Opening Bids", [
            "1NT: 15-17 HCP, balanced",
            "1♥/1♠: 12+ HCP, usually 5+ cards",
            "1♣/1♦: 12+ HCP, 3+ cards"
        ]),
        ("Responses", [
            "Support partner with 3+ cards",
            "New suit = 4+ cards, forcing for one round"
        ])
    ]

    var body: some View {
        List {
            ForEach(0..<sections.count, id: \.self) { i in
                Section(header: Text(sections[i].title)) {
                    ForEach(sections[i].items, id: \.self) { item in
                        coloredSuitText(item)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
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
