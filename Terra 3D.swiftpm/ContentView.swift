import SwiftUI
import RealityKit
import ARKit

// FIXME: modify this code after AR proof of concept
struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        // configure rendering options
        arView.renderOptions.remove(.disableCameraGrain)
        arView.renderOptions.remove(.disableGroundingShadows)
        arView.renderOptions.remove(.disablePersonOcclusion)
        
        let anchor = AnchorEntity(plane: .horizontal)
        let terrain = TerrainMesh()
        anchor.addChild(terrain)
        
        
        arView.scene.addAnchor(anchor)
        
        // Set debug options: Comment out due to uncertainty of the judging process
        //        #if DEBUG
        //        arView.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry, .showWorldOrigin, .showSceneUnderstanding]
        //        #endif
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
}


struct ContentView: View {
    var body: some View {
        ZStack{
            ARViewContainer()
        }
        .ignoresSafeArea(.all)
    }
}
