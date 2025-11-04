import SwiftUI

@main
struct BridgeTutorApp: App {
    @StateObject private var gameManager = BridgeGameManager()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    ContentView()
                        .environmentObject(gameManager)
                }
            }
        }
    }
}

struct SplashView: View {
    @State private var scale: CGFloat = 0.9
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
                Text("Bridge Bidding Tutor").font(.title).fontWeight(.semibold)
                Text("Systems • Conventions • Practice").font(.subheadline).foregroundColor(.secondary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) { scale = 1.0; opacity = 1.0 }
            }
        }
    }
}
