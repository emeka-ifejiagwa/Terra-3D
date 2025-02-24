//
//  GreenHouseEmissions.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit

class GreenHouseEmissions: System {
    private var timeSinceTextureUpdate = 0.0
    private var updateInterval = SimulationConfig.updateInterval
    private static let query = EntityQuery(where: .has(GreenHouseComponent.self)
                                           && .has(SequestrationComponent.self)
                                           && .has(PollutionComponent.self))
    static var dependencies: [SystemDependency] = []
    
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        // update after every set milliseconds
        timeSinceTextureUpdate += context.deltaTime
        guard timeSinceTextureUpdate >= updateInterval else {return}
        timeSinceTextureUpdate = 0
        
        context.entities(matching: GreenHouseEmissions.query, updatingSystemWhen: .rendering)
            .forEach { entity in
                var ghgComponent = entity.components[GreenHouseComponent.self]!
                let sequestration = entity.components[SequestrationComponent.self]!
                let pollution = entity.components[PollutionComponent.self]!
                
                let updatedGlobalEmission = ghgComponent.globalEmissions + pollution.industrialEmission + pollution.landUseEmission
                ghgComponent.globalEmissions = updatedGlobalEmission
                ghgComponent.totalGHGConcentration += updatedGlobalEmission - sequestration.sequestrationRate
                ghgComponent.totalGHGConcentration = max(ghgComponent.totalGHGConcentration, 1)
//                print(ghgComponent)
                entity.components[GreenHouseComponent.self] = ghgComponent
            }
    }
}
