import SwiftUI
import RealityKit

struct ContentView: View {
    var simManager: SimManager
    var body: some View {
        switch simManager.currentAppState {
        case .intro:
            IntroView(simManager: simManager)
        case .userSelection:
            SimulationOptionsView(simManager: simManager)
        case .simulation:
            SimulationARView()
        default:
            HomeView(simManager: simManager)
        }
    }
}
