import SwiftUI

struct ContentView: View {
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
            }
            .navigationBarHidden(true)
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
    let text: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)

            Text(text)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
                .overlay(
                    coloredCardText(text)
                        .font(.system(size: 28, weight: .semibold))
                )
        }
        .frame(width: 90, height: 120)
    }
}

private func coloredCardText(_ text: String) -> Text {
    var result = Text("")
    for ch in text {
        let t = Text(String(ch)).foregroundColor((ch == "♥" || ch == "♦") ? .red : .primary)
        result = result + t
    }
    return result
}

#Preview {
    ContentView()
}
