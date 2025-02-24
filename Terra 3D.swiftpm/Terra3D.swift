import SwiftUI

@main
struct Terra3D: App {
    var body: some Scene {
        WindowGroup {
            @State var simManager = SimManager()
            ContentView(simManager: simManager)
                .preferredColorScheme(.dark)
                .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
