import SwiftUI
import RealityKit

// FIXME: modify this code after AR proof of concept
struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        // for testing purposes
        let waterMesh = MeshResource.generateBox(size: 0.2)
        let waterMaterial = SimpleMaterial(color: .cyan, roughness: 0.5, isMetallic: true)
        let water = ModelEntity(mesh: waterMesh, materials: [waterMaterial])
        water.components[OpacityComponent.self] = .init(opacity: 0.5)
        
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(water)
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
