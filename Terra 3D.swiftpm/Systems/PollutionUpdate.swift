//
//  PollutionUpdate.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit

class PollutionUpdate: System {
    private var timeSinceTextureUpdate = 0.0
    private var updateInterval = SimulationConfig.updateInterval
    private static let query = EntityQuery(where: .has(PollutionComponent.self)
                                           && .has(HumanComponent.self))
    
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        // update after every set milliseconds
        timeSinceTextureUpdate += context.deltaTime
        guard timeSinceTextureUpdate >= updateInterval else {return}
        timeSinceTextureUpdate = 0
        
        context.entities(matching: PollutionUpdate.query, updatingSystemWhen: .rendering)
            .forEach { entity in
                var pollution = entity.components[PollutionComponent.self]!
                let humanComponent = entity.components[HumanComponent.self]!
                
                var industrialEmission = pollution.industrialEmission * humanComponent.urbanization * (1 - PollutionParams.pollutionDecay)
                industrialEmission += PollutionParams.baseIndustrialEmission
                
                var landUseEmission = pollution.landUseEmission * humanComponent.population * (1 - PollutionParams.pollutionDecay) + humanComponent.pollutionPerPerson
                landUseEmission = landUseEmission + PollutionParams.baseLandUseEmission
                
                pollution.industrialEmission = industrialEmission
                pollution.landUseEmission = landUseEmission
                
                entity.components[PollutionComponent.self] = pollution
            }
    }
}
