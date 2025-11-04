import SwiftUI

struct ContentView: View {
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.02, green: 0.35, blue: 0.18), Color(red: 0.04, green: 0.45, blue: 0.24)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Bridge Bidding Tutor")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)

                        Text("Learn bridge bidding with interactive tutorials")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    VStack(spacing: 10) {
                        HStack(spacing: 14) {
                            Text("♠️").font(.system(size: 32))
                            Text("♥️").font(.system(size: 32))
                            Text("♦️").font(.system(size: 32))
                            Text("♣️").font(.system(size: 32))
                        }

                        ZStack {
                            SimpleCardView(text: "A♠", color: .white)
                                .rotationEffect(.degrees(-10))
                                .offset(x: -24)
                            SimpleCardView(text: "K♥", color: .white)
                                .rotationEffect(.degrees(0))
                            SimpleCardView(text: "Q♦", color: .white)
                                .rotationEffect(.degrees(10))
                                .offset(x: 24)
                        }
                        .frame(height: 110)
                    }

                    Spacer()

                    VStack(spacing: 16) {
                        NavigationLink(destination: BiddingTutorialView()) {
                            TutorialButton(title: "Start Tutorial", subtitle: "Learn basic bidding concepts")
                        }

                        NavigationLink(destination: PracticeView()) {
                            TutorialButton(title: "Practice Mode", subtitle: "Practice with random hands")
                        }

                        NavigationLink(destination: BiddingGuideView()) {
                            TutorialButton(title: "Bidding Guide", subtitle: "Reference for bidding systems")
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .overlay(alignment: .topTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .padding(12)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

struct TutorialButton: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.85))
        }
        .padding()
        .background(Color.white.opacity(0.12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.15), lineWidth: 1))
        .cornerRadius(12)
    }
}

private struct SimpleCardView: View {
    let text: String   // e.g., "A♠", "K♥", "Q♦"
    let color: Color

    private var rank: String {
        // Everything except last scalar if that last is a suit
        let suits: Set<Character> = ["♠","♥","♦","♣"]
        if let last = text.last, suits.contains(last) {
            return String(text.dropLast())
        }
        return text
    }

    private var suit: String {
        let suits: Set<Character> = ["♠","♥","♦","♣"]
        if let last = text.last, suits.contains(last) {
            return String(last)
        }
        return "♠"
    }

    private var isRed: Bool { suit == "♥" || suit == "♦" }

    var body: some View {
        ZStack {
            // Card base
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)

            // Corner indices
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rank)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isRed ? .red : .primary)
                        Text(suit)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isRed ? .red : .primary)
                    }
                    .padding(8)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(rank)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isRed ? .red : .primary)
                            .rotationEffect(.degrees(180))
                        Text(suit)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isRed ? .red : .primary)
                            .rotationEffect(.degrees(180))
                    }
                    .padding(8)
                }
            }

            // No central art: minimalist card showing only corner indices
        }
        .frame(width: 90, height: 120)
    }
}

private func isRedSuit(_ text: String) -> Bool {
    text.contains("♥") || text.contains("♦")
}

private struct SettingsView: View {
    @EnvironmentObject var gameManager: BridgeGameManager
    @Environment(\.dismiss) private var dismiss
    @State private var selection: BridgeGameManager.BiddingSystem = .standardAmerican

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

            NavigationView {
                List {
                    Section(header: Text("Bidding System").foregroundColor(.white)) {
                        Picker("System", selection: $selection) {
                            ForEach(BridgeGameManager.BiddingSystem.allCases, id: \.self) { sys in
                                Text(label(for: sys)).tag(sys)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selection) { newValue in
                            gameManager.activeSystem = newValue
                        }
                        .onAppear { selection = gameManager.activeSystem }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
    }

    private func label(for sys: BridgeGameManager.BiddingSystem) -> String {
        switch sys {
        case .standardAmerican: return "Standard American"
        case .polishClub: return "Polish Club"
        case .twoOverOne: return "2/1 GF"
        }
    }
}

#Preview {
    ContentView()
}
