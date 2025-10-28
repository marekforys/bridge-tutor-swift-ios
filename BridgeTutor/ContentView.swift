import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Bridge Bidding Tutor")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Learn bridge bidding with interactive tutorials")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

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
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}
