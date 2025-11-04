import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    Text("♠️").font(.system(size: 42))
                    Text("♥️").font(.system(size: 42))
                    Text("♦️").font(.system(size: 42))
                    Text("♣️").font(.system(size: 42))
                }

                Text("Bridge Bidding Tutor")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Systems • Conventions • Practice")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
