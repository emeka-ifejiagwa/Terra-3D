import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        ZStack{
            RealityView{ content in
                content.camera = .spatialTracking
//                content.renderingEffects.cameraGrain = .enabled
//                content.renderingEffects.antialiasing = .multisample4X
//                content.renderingEffects.depthOfField = .enabled
                
                let anchor = AnchorEntity(plane: .horizontal)
                let terrain = TerrainMesh()
                terrain.position = .zero
                anchor.addChild(terrain)
                content.entities.append(anchor)
                TextureUpdate.registerSystem()
                Erosion.registerSystem()
            }
        }
        .ignoresSafeArea(.all)
    }
}
