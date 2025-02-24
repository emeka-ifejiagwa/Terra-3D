//
//  SimulationARView.swift
//  Terra 3D
//
//  Created by Jiexy on 2/24/25.
//

import SwiftUI
import RealityKit

struct SimulationARView: View {
    var body: some View {
        ZStack{
            RealityView{ content in
                content.camera = .spatialTracking
                content.renderingEffects.cameraGrain = .enabled
                content.renderingEffects.depthOfField = .disabled
                content.renderingEffects.antialiasing = .none
                content.renderingEffects.motionBlur = .disabled
                
                let anchor = AnchorEntity(plane: .horizontal)
                let terrain = Terrain()
                terrain.position = .zero
                anchor.addChild(terrain)
                content.entities.append(anchor)
                
                GreenHouseEmissions.registerSystem()
                SequestrationUpdate.registerSystem()
                TemperatureUpdate.registerSystem()
                HumidityUpdate.registerSystem()
                VegetationUpdate.registerSystem()
                PollutionUpdate.registerSystem()
                HumanInteractions.registerSystem()
                TextureUpdate.registerSystem()
            }
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    SimulationARView()
}
