import SwiftUI

struct BiddingTutorialView: View {
    @EnvironmentObject var gameManager: BridgeGameManager

    var body: some View {
        List {
            Section(header: Text("Systems")) {
                NavigationLink(destination: PolishClubTutorialView()) {
                    Text("Polish Club")
                }
            }
            Section(header: Text("Conventions")) {
                NavigationLink(destination: ConventionsTutorialView()) {
                    Text("Common Conventions")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Tutorials")
    }
}

struct PolishClubTutorialView: View {
    var body: some View {
        List {
            Section(header: Text("Polish Club — basics")) {
                coloredSuitText("1♣: strong, artificial (typically 12+ HCP, wide range)")
                coloredSuitText("1♦: natural, 4+ ♦, ~11–17 HCP")
                coloredSuitText("1♥/1♠: natural, 5+ cards")
                coloredSuitText("1NT: 15–17 HCP, balanced")
            }

            Section(header: Text("Opening structure")) {
                coloredSuitText("1♣: any strong hand; can be balanced or unbalanced")
                coloredSuitText("1♦: 11–17, 4+ ♦ (may include some balanced hands)")
                coloredSuitText("1♥/1♠: 11–17, usually 5+ cards (can be 4 in some styles)")
                coloredSuitText("1NT: 15–17, balanced; 2NT: 20–21, balanced")
                coloredSuitText("2♣/2♦: natural, 5+ suit, strong (often GF) — style varies")
            }

            Section(header: Text("Responses to 1♣")) {
                coloredSuitText("1♦: 0–7 HCP, waiting/negative (catch‑all)")
                coloredSuitText("1♥/1♠: 8+ HCP, 4+ in the suit")
                coloredSuitText("1NT: 8–10 HCP, balanced, no 4‑card major")
                coloredSuitText("2♣/2♦: natural, 5+ suit, game‑forcing values")
                coloredSuitText("2♥/2♠: natural, good suit, invitational+ (style dependent)")
            }

            Section(header: Text("Opener after 1♣–1♦ (negative)")) {
                coloredSuitText("1♥/1♠: natural, shows a 4+ major (may be 5)")
                coloredSuitText("1NT: 18–19 balanced")
                coloredSuitText("2♣/2♦: natural, 5+ suit, strong")
                coloredSuitText("2NT: 22–23 balanced")
                coloredSuitText("Jump bids: strong, usually GF with a good suit")
            }

            Section(header: Text("Responder after 1♣–1♦; continuations")) {
                coloredSuitText("Support opener’s major with 3+ support (invite/GF per style)")
                coloredSuitText("New suit: natural, shows values; set GF if agreed in partnership")
                coloredSuitText("Notrump: shows balanced ranges per step (e.g., 8–10, 11–12, …)")
            }

            Section(header: Text("Interference over 1♣ (simplified)")) {
                coloredSuitText("Double: often shows values; responder can use systems‑on/off per style")
                coloredSuitText("Overcall: natural; negative/waiting responses adapt (e.g., pass = weak)")
                coloredSuitText("Cue‑bid: shows support or strong hands—agree methods with partner")
            }

            Section(header: Text("Example sequences")) {
                coloredSuitText("1♣ – 1♦; 1♥ – 2♥: negative, opener shows ♥, responder raises with 3+")
                coloredSuitText("1♣ – 1♦; 1NT – 2NT: 18–19 bal; invitational values by responder")
                coloredSuitText("1♣ – 1♠; 2♣ – 3♣: GF with clubs agreed, exploring slam")
            }

            Section {
                NavigationLink(destination: PracticeView()) {
                    HStack {
                        Spacer()
                        Text("Practice this")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                        Spacer()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Polish Club")
    }
}

struct ConventionsTutorialView: View {
    var body: some View {
        List {
            Section(header: Text("Stayman over 1NT")) {
                coloredSuitText("2♣: asks for a 4‑card major (after 1NT)")
                coloredSuitText("2♦: denies any 4‑card major")
                coloredSuitText("2♥: shows 4♥ (may also hold 4♠)")
                coloredSuitText("2♠: shows 4♠; with 4‑4 majors, bid 2♦ then 2♥ per style")
                coloredSuitText("Responder: invite/game decisions based on fits and HCP")
            }

            Section(header: Text("Jacoby transfers over 1NT")) {
                coloredSuitText("2♦: transfer to ♥; opener bids 2♥")
                coloredSuitText("2♥: transfer to ♠; opener bids 2♠")
                coloredSuitText("Responder follow‑ups: invite with 2NT/3M; GF with 3M or new suit")
                coloredSuitText("Super‑accepts: opener may jump with 4‑card support and max")
            }

            Section(header: Text("RKCB 1430 (simplified)")) {
                coloredSuitText("4NT: keycard ask in agreed trump suit")
                coloredSuitText("5♣: 1 or 4 keycards; 5♦: 0 or 3 keycards")
                coloredSuitText("5♥: Q‑trump ask or specific king asks per partnership style")
                coloredSuitText("Control bidding: cue first‑round controls before keycard when helpful")
            }

            Section {
                NavigationLink(destination: PracticeView()) {
                    HStack {
                        Spacer()
                        Text("Practice this")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                        Spacer()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Conventions")
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
