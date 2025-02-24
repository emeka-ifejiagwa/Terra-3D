//
//  SequestrationUpdate.swift
//  Terra 3D
//
//  Created by Jiexy on 2/23/25.
//

import RealityKit

class SequestrationUpdate: System {
    private var timeSinceTextureUpdate = 0.0
    private var updateInterval = SimulationConfig.updateInterval
    private static let query = EntityQuery(where: .has(SequestrationComponent.self)
                                           && .has(GreenHouseComponent.self)
                                           && .has(HumanComponent.self)
                                           && .has(VegetationComponent.self))
    
    required init(scene: Scene) { }
    func update(context: SceneUpdateContext) {
        // update after every set milliseconds
        timeSinceTextureUpdate += context.deltaTime
        guard timeSinceTextureUpdate >= updateInterval else {return}
        timeSinceTextureUpdate = 0
        
        context.entities(matching: SequestrationUpdate.query, updatingSystemWhen: .rendering)
            .forEach { entity in
                var sequestration = entity.components[SequestrationComponent.self]!
                let ghgComponent = entity.components[GreenHouseComponent.self]!
                let vegetation = entity.components[VegetationComponent.self]!
                let human = entity.components[HumanComponent.self]!
                
                let vegetativeSequestration = (vegetation.vegetativeCover +  3 * human.forestation) * SequestrationParams.seqPerVegetation
                // always sequestrate 10 percent of green house gas emission
                let ghgSeq = (ghgComponent.totalGHGConcentration - GHGParams.baselineConcentration) * SequestrationParams.ghgSinkFactor
                sequestration.sequestrationRate = SequestrationParams.baseSequestrationAmount + ghgSeq + vegetativeSequestration
                
//                print(vegetativeSequestration)
                // update sequestration
                entity.components[SequestrationComponent.self] = sequestration
            }
    }
}
