import SwiftUI

@main
struct BridgeTutorApp: App {
    @StateObject private var gameManager = BridgeGameManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
        }
    }
}
